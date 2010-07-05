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