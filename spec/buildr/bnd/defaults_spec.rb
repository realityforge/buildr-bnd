require File.expand_path('../../../spec_helper', __FILE__)

describe "project.bnd defaults" do

  before do
    @foo = define "foo" do
      project.version = "2.1.3"
      project.group = "mygroup"
      package :bundle
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
end
