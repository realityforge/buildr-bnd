buildr-bnd
----------

buildr-bnd is a Buildr (http://buildr.apache.org/) extension for packaging
OSGi bundles using Bnd (http://www.aqute.biz/Code/Bnd). The extension allows
the user to define properties/directives to be supplied to the Bnd tool and
provides reasonable defaults for those that can be derived from the project
model. The extension also defines the bundle package type for buildr.

A typical project that uses the extension may look something like;

define 'myProject' do
  ...
  bnd['Import-Package'] = "*;resolution:=optional"
  bnd['Export-Package'] = "*;version=#{version}"
  package :bundle
  ...
end

For actual examples, look in the examples dir.

How-To
------

The easiest way to use the extension is download and install it locally inside
the project that you intend to use it in. Piston (http://piston.rubyforge.org/)
is the tool I tend to use to manage vendor branches of code.

To install piston use "gem install piston". Then create a directory to contain
vendor branches. By convention I use "vendor/buildr" as the base directory for
buildr extensions. Then import this extension via a command such as;

$ piston import git://github.com/rockninja/buildr-bnd.git vendor/buildr/buildr-bnd

The files patched and modified locally and committed into the local source
control system but if you ever need to update to the latest version of this
extension use;

$ piston update vendor/buildr/buildr-bnd

The one final modification is needed to the Buildr buildfile to tell it to load the
extension. To do this I typically have the following snippet in the build file;

Dir["#{File.dirname(__FILE__)}/vendor/buildr/*/tasks/*.rake"].each do |file|
  load file
end

Credits
-------

The plugin is a modified version https://ncisvn.nci.nih.gov/svn/psc/trunk/tasks/bnd.rake
forked at revision r4922 originally pointed at by Rhett Sutphin. Subsequent modifications
and bugs are most likely due to Peter Donald <peter at realityforge dot org>