module Buildr
  module Bnd
    module ProjectExtension
      include Extension

      first_time do
        desc "Does `bnd print` on the packaged bundle and stdouts the output for inspection"
        Project.local_task("bnd:print")
      end

      def package_as_bundle(filename)
        project.task('bnd:print' => [filename]) do |task|
          Buildr::Bnd.bnd_main("print", filename)
        end

        dirname = File.dirname(filename)
        directory(dirname)

        # Add Buildr.application.buildfile so it will rebuild if we change settings
        task = BundleTask.define_task(filename => [Buildr.application.buildfile, dirname])
        task.project = self
        # the last task is the task considered the packaging task
        task
      end

      def package_as_bundle_spec(spec)
        # Change the source distribution to .jar extension
        spec.merge(:type => :jar)
      end
    end
  end
end

class Buildr::Project
  include Buildr::Bnd::ProjectExtension
end