module Buildr
  module Bnd
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
        cp = Buildr.artifacts(self.requires).each(&:invoke).map(&:to_s)
        Java::Commands.java 'aQute.bnd.main.bnd', *(args + [{ :classpath => cp }])
      end
    end
  end
end
