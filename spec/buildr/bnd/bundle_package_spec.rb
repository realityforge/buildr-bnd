require File.expand_path('../../../spec_helper', __FILE__)

describe "package :bundle" do

  before do
    write "src/main/java/com/biz/Foo.java",<<SRC
package com.biz;
public class Foo {}
SRC
    write "bar/src/main/java/com/biz/bar/Bar.java",<<SRC
package com.biz.bar;
public class Bar {}
SRC
    @foo = define "foo" do
      project.version = "2.1.3"
      project.group = "mygroup"
      manifest["Magic-Food"] = "Chocolate"
      manifest["Magic-Drink"] = "Wine"
      package :bundle

      define "bar" do
        project.version = "2.2"
        manifest["Magic-Food"] = "Cheese"
        package :bundle
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


  def open_zip_file
    jar_filename = @foo._("target/foo-2.1.3.jar")
    File.should be_exist(jar_filename)
    Zip::ZipFile.open(jar_filename) do |zip|
      yield zip
    end
  end

  def open_main_manifest_section
    jar_filename = @foo._("target/foo-2.1.3.jar")
    File.should be_exist(jar_filename)
    yield Buildr::Packaging::Java::Manifest.from_zip(jar_filename).main
  end
end
