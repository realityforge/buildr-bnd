module Buildr
  module Bnd
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

          Buildr::Bnd.bnd_main( "build", "-noeclipse", bnd_filename )
          begin
            Buildr::Bnd.bnd_main( "print", "-verify", filename )
          rescue => e
            rm filename
            raise e
          end
        end
      end
    end
  end
end
