Gem::Specification.new do |spec|
  spec.name           = 'buildr-bnd'
  spec.version        = `git describe`.strip.split('-').first
  spec.authors        = ['Peter Donald']
  spec.email          = ["peter@realityforge.org"]
  spec.homepage       = "http://github.com/rockninja/buildr-bnd"
  spec.summary        = "Buildr extension for packaging OSGi bundles using bnd"
  spec.description    = <<-TEXT
This is a buildr extension for packaging OSGi bundles using Bnd. 
  TEXT
  spec.files          = Dir['{lib,spec}/**/*', '*.gemspec'] +
                        ['LICENSE', 'NOTICE', 'README.txt', 'Rakefile']
  spec.require_paths  = ['lib']

  spec.has_rdoc         = true
  spec.extra_rdoc_files = 'README.txt', 'LICENSE', 'NOTICE'
  spec.rdoc_options     = '--title', "#{spec.name} #{spec.version}", '--main', 'README.txt'
end
