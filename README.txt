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

Credits
-------

The plugin is a modified version https://ncisvn.nci.nih.gov/svn/psc/trunk/tasks/bnd.rake
forked at revision r4922 originally pointed at by Rhett Sutphin. Subsequent modifications
and bugs are most likely due to Peter Donald <peter at realityforge dot org>