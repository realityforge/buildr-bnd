require File.expand_path('../../../spec_helper', __FILE__)

def open_zip_file(file = 'target/foo-2.1.3.jar')
  jar_filename = @foo._(file)
  File.should be_exist(jar_filename)
  Zip::ZipFile.open(jar_filename) do |zip|
    yield zip
  end
end

def open_main_manifest_section(file = 'target/foo-2.1.3.jar')
  jar_filename = @foo._(file)
  File.should be_exist(jar_filename)
  yield Buildr::Packaging::Java::Manifest.from_zip(jar_filename).main
end

describe "package :bundle" do
  describe "with a valid bundle" do
    before do
      write "src/main/java/com/biz/Foo.java", <<SRC
package com.biz;
public class Foo {}
SRC
      write "bar/src/main/java/com/biz/bar/Bar.java", <<SRC
package com.biz.bar;
public class Bar {}
SRC
      @foo = define "foo" do
        project.version = "2.1.3"
        project.group = "mygroup"
        manifest["Magic-Food"] = "Chocolate"
        manifest["Magic-Drink"] = "Wine"
        package(:bundle).tap do |bnd|
          bnd["Export-Package"] = "*"
        end

        define "bar" do
          project.version = "2.2"
          package(:bundle).tap do |bnd|
            bnd["Magic-Food"] = "Cheese"
            bnd["Export-Package"] = "*"
          end
        end
      end
      task('package').invoke
    end

    it "produces a .bnd in the correct location for root project" do
      File.should be_exist(@foo._("target/foo-2.1.3.bnd"))
    end

    it "produces a .jar in the correct location for root project" do
      File.should be_exist(@foo._("target/foo-2.1.3.jar"))
    end

    it "produces a .jar containing correct .class files for root project" do
      open_zip_file do |zip|
        zip.file.exist?('com/biz/Foo.class').should be_true
      end
    end

    it "produces a .jar containing expected manifest entries derived from project.bnd for root project" do
      open_main_manifest_section do |attribs|
        attribs['Bundle-Name'].should eql('foo')
        attribs['Bundle-Version'].should eql('2.1.3')
        attribs['Bundle-SymbolicName'].should eql('mygroup.foo')
        attribs['Export-Package'].should eql('com.biz')
        attribs['Import-Package'].should eql('com.biz')
      end
    end

    it "produces a .jar containing expected manifest entries derived from project.manifest root project" do
      open_main_manifest_section do |attribs|
        attribs['Magic-Drink'].should eql('Wine')
        attribs['Magic-Food'].should eql('Chocolate')
      end
    end

    it "produces a .bnd in the correct location for subproject project" do
      File.should be_exist(@foo._("bar/target/foo-bar-2.2.bnd"))
    end

    it "produces a .jar in the correct location for subproject project" do
      File.should be_exist(@foo._("bar/target/foo-bar-2.2.jar"))
    end

    it "produces a .jar containing correct .class files for subproject project" do
      open_zip_file('bar/target/foo-bar-2.2.jar') do |zip|
        zip.file.exist?('com/biz/bar/Bar.class').should be_true
      end
    end

    it "produces a .jar containing expected manifest entries derived from project.bnd for subproject project" do
      open_main_manifest_section('bar/target/foo-bar-2.2.jar') do |attribs|
        attribs['Bundle-Name'].should eql('foo:bar')
        attribs['Bundle-Version'].should eql('2.2')
        attribs['Bundle-SymbolicName'].should eql('mygroup.foo.bar')
        attribs['Export-Package'].should eql('com.biz.bar')
        attribs['Import-Package'].should eql('com.biz.bar')
      end
    end

    it "produces a .jar containing expected manifest entries derived from project.manifest subproject project" do
      open_main_manifest_section('bar/target/foo-bar-2.2.jar') do |attribs|
        attribs['Magic-Drink'].should eql('Wine')
        attribs['Magic-Food'].should eql('Cheese')
      end
    end
  end

  describe "with an invalid bundle" do
    before do
      # bundle invalid as no source
      @foo = define "foo" do
        project.version = "2.1.3"
        project.group = "mygroup"
        package(:bundle).tap do |bnd|
          bnd["Export-Package"] = "*"
        end
      end
    end

    it "raise an error if unable to build a valid bundle" do
      lambda { task('package').invoke }.should raise_error
    end

    it "raise not produce an invalid jar file" do
      lambda { task('package').invoke }.should raise_error
      File.should_not be_exist(@foo._("target/foo-2.1.3.jar"))
    end
  end

  describe "using classpath_element to specify dependency" do
    before do
      @foo = define "foo" do
        project.version = "2.1.3"
        project.group = "mygroup"
        package(:bundle).tap do |bnd|
          bnd['Export-Package'] = 'org.apache.tools.zip.*'
          Buildr::Ant.dependencies.each do |d|
            bnd.classpath_element d
          end
        end
      end
    end

    it "should not raise an error during packaging" do
      lambda { task('package').invoke }.should_not raise_error
    end

    it "should generate package with files exported from dependency" do
      task('package').invoke
      open_main_manifest_section do |attribs|
        attribs['Export-Package'].should eql('org.apache.tools.zip')
      end
    end
  end

  describe "using compile dependencies to specify dependency" do
    before do
      @foo = define "foo" do
        project.version = "2.1.3"
        project.group = "mygroup"
        compile.with Buildr::Ant.dependencies
        package(:bundle).tap do |bnd|
          bnd['Export-Package'] = 'org.apache.tools.zip.*'
        end
      end
    end

    it "should not raise an error during packaging" do
      lambda { task('package').invoke }.should_not raise_error
    end

    it "should generate package with files exported from dependency" do
      task('package').invoke
      open_main_manifest_section do |attribs|
        attribs['Export-Package'].should eql('org.apache.tools.zip')
      end
    end
  end
end
