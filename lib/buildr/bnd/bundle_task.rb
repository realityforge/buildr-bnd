module Buildr
  module Bnd
    class BundleTask < Rake::FileTask
      attr_reader :project
      attr_accessor :classpath

      def [](key)
        @params[key]
      end

      def []=(key, value)
        @params[key] = value
      end

      def classpath_element(dependencies)
        artifacts = Buildr.artifacts([dependencies])
        self.prerequisites << artifacts
        artifacts.each do |dependency|
          self.classpath << dependency.to_s
        end
      end

      def to_params
        params = self.project.manifest.merge(@params).reject { |k, v| v.nil? }
        params["-classpath"] ||= self.classpath.collect(&:to_s).join(", ")
        params['Bundle-SymbolicName'] ||= [self.project.group, self.project.name.gsub(':', '.')].join('.')
        params['Bundle-Name'] ||= self.project.comment || self.project.name
        params['Bundle-Description'] ||= self.project.comment
        params['Bundle-Version'] ||= self.project.version

        params
      end

      def project=(project)
        @project = project
      end

      def classpath=(classpath)
        @classpath = []
        Buildr.artifacts([classpath.flatten.compact]).each do |dependency|
          self.prerequisites << dependency
          @classpath << dependency.to_s
        end
        @classpath
      end

      def classpath
        @classpath ||= ([project.compile.target] + project.compile.dependencies).flatten.compact
      end

      protected

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
