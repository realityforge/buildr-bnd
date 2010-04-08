module Realityforge
  module Bnd
    REQUIRES = ["biz.aQute:bnd:jar:0.0.384"]

    include Buildr::Extension

    class << self

      def bnd_main(*args)
        cp = Buildr.artifacts(REQUIRES).each(&:invoke).map(&:to_s).join(File::PATH_SEPARATOR)
        Java::Commands.java 'aQute.bnd.main.bnd', *(args + [{ :classpath => cp }])
      end

    end

    def package_as_bundle(filename)
      dirname = File.dirname(filename)
      # Generate BND file with same name as target jar but different extension
      bnd_filename = filename.sub /(\.jar)?$/, '.bnd'

      directory( dirname )

      # Add Buildr.application.buildfile so it will rebuild if we change settings
      project.file(bnd_filename => [Buildr.application.buildfile, dirname]) do |task|
        project.bnd["-output"] = filename
        params = project.bnd.merge(project.manifest).reject { |k, v| v.nil? || v.empty? }
        File.open(task.name, 'w') do |f|
          f.print params.collect { |k, v| "#{k}=#{v}" }.join("\n")
        end
      end

      project.task('bnd:print' => [filename]) do |task|
        Bnd.bnd_main( filename )
      end

      # the last task is the task considered the packaging task
      project.file( filename => [bnd_filename] ) do |task|
        Bnd.bnd_main( "build", "-noeclipse", bnd_filename )
        Bnd.bnd_main( "print", "-verify", filename )
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

    before_define do |project|
      if project.parent
        project.bnd.merge(project.parent.bnd)
      end
    end

    after_define do |project|
      project.bnd.classpath ||= ([project.compile.target] + project.compile.dependencies).collect(&:to_s).join(", ")
      project.bnd['Bundle-SymbolicName'] ||= [project.group, project.id].join('.')
      project.bnd['Bundle-Name'] ||= project.comment || project.name
      project.bnd['Bundle-Description'] ||= project.full_comment
      project.bnd['Bundle-Version'] ||= project.version
      project.bnd['Import-Package'] ||= '*'
      project.bnd['Export-Package'] ||= '*'
    end

    def bnd
      @bnd ||= BndParameters.new
    end

    class BndParameters < Hash
      def classpath=(classpath)
        self["-classpath"] = classpath
      end

      def classpath
        self["-classpath"]
      end
    end
  end
end

class Buildr::Project
  include Realityforge::Bnd
end