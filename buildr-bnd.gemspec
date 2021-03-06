require File.expand_path(File.dirname(__FILE__) + '/lib/buildr/bnd/version')

Gem::Specification.new do |spec|
  spec.name           = 'buildr-bnd'
  spec.version        = Buildr::Bnd::Version::STRING
  spec.authors        = ['Peter Donald']
  spec.email          = ["peter@realityforge.org"]
  spec.homepage       = "http://github.com/realityforge/buildr-bnd"
  spec.summary        = "Buildr extension for packaging OSGi bundles using bnd"
  spec.description    = <<-TEXT
This is a buildr extension for packaging OSGi bundles using Bnd. 
  TEXT
  spec.files          = Dir['{lib,spec}/**/*', '*.gemspec'] +
                        ['LICENSE', 'README.rdoc', 'CHANGELOG', 'Rakefile']
  spec.require_paths  = ['lib']

  spec.has_rdoc         = true
  spec.extra_rdoc_files = 'README.rdoc', 'LICENSE', 'CHANGELOG'
  spec.rdoc_options     = '--title', "#{spec.name} #{spec.version}", '--main', 'README.rdoc'
end
