require File.expand_path('../../../spec_helper', __FILE__)

describe "project.bnd defaults" do

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
      package :bundle
      compile.with Buildr::Ant.dependencies
      desc "My Bar Project"
      define "bar" do
        package :bundle
      end
    end
    @bar = @foo.project('bar')
  end

  it "defaults Bundle-Version to project.version" do
    @foo.packages[0].to_params['Bundle-Version'].should eql('2.1.3')
    @bar.packages[0].to_params['Bundle-Version'].should eql('2.1.3')
  end

  it "defaults -classpath to compile path and dependencies" do
    @foo.packages[0].to_params['-classpath'].should include(@foo.compile.target.to_s)
    @foo.packages[0].to_params['-classpath'].should include(Buildr.artifacts(Buildr::Ant.dependencies[0]).to_s)
    @bar.packages[0].to_params['-classpath'].should include(@bar.compile.target.to_s)
  end

  it "classpath method returns compile path and dependencies" do
    @foo.packages[0].classpath.should include(@foo.compile.target)
    Buildr::Ant.dependencies.each do |dependency|
      @foo.packages[0].classpath.to_s.should include(Buildr.artifacts(dependency).to_s)
    end
    @bar.packages[0].classpath.should include(@bar.compile.target)
  end

  it "defaults Bundle-SymbolicName to combination of group and name" do
    @foo.packages[0].to_params['Bundle-SymbolicName'].should eql('mygroup.foo')
    @bar.packages[0].to_params['Bundle-SymbolicName'].should eql('mygroup.foo.bar')
  end

  it "defaults Export-Package to nil" do
    @foo.packages[0].to_params['Export-Package'].should be_nil
    @bar.packages[0].to_params['Export-Package'].should be_nil
  end

  it "defaults Import-Package to nil" do
    @foo.packages[0].to_params['Import-Package'].should be_nil
    @bar.packages[0].to_params['Import-Package'].should be_nil
  end

  it "defaults Bundle-Name to project.name if comment not present" do
    @foo.packages[0].to_params['Bundle-Name'].should eql('foo')
  end

  it "defaults Bundle-Name to comment if present" do
    @bar.packages[0].to_params['Bundle-Name'].should eql('My Bar Project')
  end

  it "defaults Bundle-Description to project.full_comment" do
    @foo.packages[0].to_params['Bundle-Description'].should be_nil
    @bar.packages[0].to_params['Bundle-Description'].should eql('My Bar Project')
  end

  it "defaults -removeheaders to" do
    @foo.packages[0].to_params['-removeheaders'].should eql("Include-Resource,Bnd-LastModified,Created-By,Implementation-Title,Tool")
  end
end
