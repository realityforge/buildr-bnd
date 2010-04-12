module Buildr
  module Bnd
    include Buildr::Extension

    class << self

      # The specs for requirements
      def requires
        ["biz.aQute:bnd:jar:0.0.384"]
      end

      # Repositories containing the requirements
      def remote_repositories
        ["http://www.aQute.biz/repo"]
      end

      def bnd_main(*args)
        cp = Buildr.artifacts(self.requires).each(&:invoke).map(&:to_s).join(File::PATH_SEPARATOR)
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
        params = project.bnd.to_params
        params["-output"] = filename
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
        begin
          Bnd.bnd_main( "print", "-verify", filename )
        rescue => e
          rm filename
          raise e
        end
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

    def bnd
      @bnd ||= BndParameters.new( self )
    end

    class BndParameters < Hash
      def initialize(project)
        @project = project
      end

      def to_params
        params = @project.manifest.merge(self).reject { |k, v| v.nil? }
        params["-classpath"] ||= ([@project.compile.target] + @project.compile.dependencies).collect(&:to_s).join(", ")
        params['Bundle-SymbolicName'] ||= [@project.group, @project.name.gsub(':','.')].join('.')
        params['Bundle-Name'] ||= @project.comment || @project.name
        params['Bundle-Description'] ||= @project.comment
        params['Bundle-Version'] ||= @project.version
        params['Import-Package'] ||= '*'
        params['Export-Package'] ||= '*'

        params
      end
    end
  end
end

class Buildr::Project
  include Buildr::Bnd
end