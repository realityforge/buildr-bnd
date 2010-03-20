module Bnd
  REQUIRES = ["biz.aQute:bnd:jar:0.0.384"]

  include Buildr::Extension

  def package_as_bundle(filename)
    dirname = File.dirname(filename)
    # Generate BND file with same name as target jar but different extension
    bnd_filename = filename.sub /(\.jar)?$/, '.bnd'

    directory( dirname )

    # Add Buildr.application.buildfile so it will rebuild if we change settings
    project.file(bnd_filename => [Buildr.application.buildfile, dirname]) do |task|
      File.open(task.name, 'w') do |f|
        project.bnd["-output"] = filename
        project.bnd['-failok'] = "true"
        project.bnd.write(f)
      end
    end

    project.task('bnd:print' => [filename]) do |task|
      bnd_main( filename )
    end

    # the last task is the task considered the packaging task
    project.file( filename => [bnd_filename] ) do |task|
      bnd_main( "build", "-noeclipse", bnd_filename )
      bnd_main( "print", "-verify", filename )
    end
  end

  def package_as_bundle_spec(spec)
    # Change the source distribution to .jar extension
    spec.merge( :type => :jar )
  end

  first_time do
    desc "Does `bnd print` on the packaged bundle and stdouts the output for inspection"
    Project.local_task("bnd:print")
  end

  def bnd_main(*args)
    cp = Buildr.artifacts(REQUIRES).each(&:invoke).map(&:to_s).join(File::PATH_SEPARATOR)
    Java::Commands.java 'aQute.bnd.main.bnd', *(args + [{ :classpath => cp }])
  end

  def bnd
    @bnd ||= ProjectBndProperties.new(self)
  end

  module BndProperties
    BND_TO_ATTR = {
        '-classpath' => :classpath,
        'Bundle-Version' => :version,
        'Bundle-SymbolicName' => :symbolic_name,
        'Bundle-Name' => :name,
        'Bundle-Description' => :description,
        'Import-Package' => :import_packages_serialized,
        'Export-Package' => :export_packages_serialized
    }
    LIST_ATTR = BND_TO_ATTR.values.select { |a| a.to_s =~ /_serialized$/ }
    SCALAR_ATTR = BND_TO_ATTR.values - LIST_ATTR

    # Scalar properties are deliberately not memoized to allow
    # the default values to be evaluated as late as possible.

    SCALAR_ATTR.each do |attribute|
      class_eval <<-RUBY
        def #{attribute}
          @#{attribute} || (default_#{attribute} if respond_to? :default_#{attribute})
        end
      RUBY
    end

    attr_writer(*SCALAR_ATTR)

    # List properties are memoized to allow for concatenation via the 
    # read accessor.

    LIST_ATTR.each do |attribute_ser|
      attribute = attribute_ser.to_s.sub(/_serialized$/, '')
      class_eval <<-RUBY
        def #{attribute}
          @#{attribute} ||= (self.respond_to?(:default_#{attribute}) ? default_#{attribute} : [])
        end
        
        def #{attribute_ser}
      #{attribute}.join(', ')
        end
        
        def #{attribute_ser}=(s)
          # XXX: this does not account for quotes
          @#{attribute} = s.split(/\\s*,\\s*/)
        end
      RUBY
    end

    def write(f)
      f.print self.to_hash.collect { |k, v| "#{k}=#{v}" }.join("\n")
    end

    def to_hash
      Hash[ *BND_TO_ATTR.keys.collect { |k| [ k, self[k] ] }.reject { |k, v| v.nil? || v.empty? }.flatten ].merge(other)
    end

    def [](k)
      if BND_TO_ATTR.keys.include?(k)
        self.send BND_TO_ATTR[k]
      else
        other[k]
      end
    end

    def []=(k, v)
      if BND_TO_ATTR.keys.include?(k)
        self.send :"#{BND_TO_ATTR[k]}=", v
      else
        other[k] = v
      end
    end

    def merge!(other)
      other.each do |k, v|
        self[k] = v
      end
      self
    end

    protected

    def other
      @other ||= { }
    end
  end

  class ProjectBndProperties
    include BndProperties

    def initialize(project)
      @project = project
    end

    def default_version
      project.version
    end

    def default_classpath
      ([project.compile.target] + project.compile.dependencies).collect(&:to_s).join(", ")
    end

    def default_symbolic_name
      [project.group, project.id].join('.')
    end

    def default_description
      project.full_comment
    end

    def default_import_packages
      ['*']
    end

    def default_export_packages
      ["*"]
    end

    protected

    def project
      @project
    end
  end
end unless Object.const_defined?(:Bnd)

class Buildr::Project
  include Bnd
end