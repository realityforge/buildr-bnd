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
        puts "Buildr::Bnd.remote_repositories is deprecated. Please use Buildr::Bnd.remote_repository instead." 
        [remote_repository]
      end

      # Repositories containing the requirements
      def remote_repository
        "http://www.aQute.biz/repo"
      end

      def bnd_main(*args)
        cp = Buildr.artifacts(self.requires).each(&:invoke).map(&:to_s).join(File::PATH_SEPARATOR)
        Java::Commands.java 'aQute.bnd.main.bnd', *(args + [{ :classpath => cp }])
      end

    end

    class BundleTask < Rake::FileTask
      attr_reader :project

      def [](key)
        @params[key]
      end

      def []=(key, value)
        @params[key] = value
      end

      def classpath_element(dependencies)
        artifacts = self.class.to_artifacts([dependencies])
        self.prerequisites << artifacts
        artifacts.each do |dependency|
          @classpath << dependency.to_s
        end
      end

      def to_params
        params = project.manifest.merge(@params).reject { |k, v| v.nil? }
        params["-classpath"] ||= @classpath.collect(&:to_s).join(", ")
        params['Bundle-SymbolicName'] ||= [project.group, project.name.gsub(':', '.')].join('.')
        params['Bundle-Name'] ||= project.comment || project.name
        params['Bundle-Description'] ||= project.comment
        params['Bundle-Version'] ||= project.version
        params['Import-Package'] ||= '*'
        params['Export-Package'] ||= '*'

        params
      end

      def project=(project)
        @project = project
        @classpath = [project.compile.target] + project.compile.dependencies
      end

      protected

      # Convert objects to artifacts, where applicable
      def self.to_artifacts(files)
        files.flatten.inject([]) do |set, file|
          case file
            when ArtifactNamespace
              set |= file.artifacts
            when Symbol, Hash
              set |= [Buildr.artifact(file)]
            when /([^:]+:){2,4}/ # A spec as opposed to a file name.
              set |= [Buildr.artifact(file)]
            when Project
              set |= Buildr.artifacts(file.packages)
            when Rake::Task
              set |= [file]
            when Struct
              set |= Buildr.artifacts(file.values)
            else
              # non-artifacts passed as-is; in particular, String paths are
              # unmodified since Rake FileTasks don't use absolute paths
              set |= [file]
          end
        end
      end

      def initialize(*args) #:nodoc:
        super
        @params = {}
        enhance do
          filename = self.name
          # Generate BND file with same name as target jar but different extension
          bnd_filename = filename.sub /(\.jar)?$/, '.bnd'

          params = self.to_params
          params["-output"] = filename
          File.open(bnd_filename, 'w') do |f|
            f.print params.collect { |k, v| "#{k}=#{v}" }.join("\n")
          end

          Bnd.bnd_main( "build", "-noeclipse", bnd_filename )
          begin
            Bnd.bnd_main( "print", "-verify", filename )
          rescue => e
            rm filename
            raise e
          end
        end
      end
    end

    def package_as_bundle(filename)
      project.task('bnd:print' => [filename]) do |task|
        Bnd.bnd_main( "print", filename )
      end

      dirname = File.dirname(filename)
      directory( dirname )

      # Add Buildr.application.buildfile so it will rebuild if we change settings
      task = BundleTask.define_task(filename => [Buildr.application.buildfile, dirname])
      task.project = self
      # the last task is the task considered the packaging task
      task
    end

    def package_as_bundle_spec(spec)
      # Change the source distribution to .jar extension
      spec.merge( :type => :jar )
    end

    first_time do
      desc "Does `bnd print` on the packaged bundle and stdouts the output for inspection"
      Project.local_task("bnd:print")
    end
  end
end

class Buildr::Project
  include Buildr::Bnd
end