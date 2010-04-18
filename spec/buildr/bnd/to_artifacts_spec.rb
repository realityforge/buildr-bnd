require File.expand_path('../../../spec_helper', __FILE__)

DEPENDENCY_NAME = 'group:id:jar:1.0'

describe "Buildr:Bnd:BundleTask.to_artifacts" do
  before do
    @artifact = artifact(DEPENDENCY_NAME) { |t| write t.to_s }
    @foo = define "foo" do
      project.version = "1.1"
      compile.with DEPENDENCY_NAME
      package :zip
    end

    @bar = define "bar" do
      project.version = "1.1"
      compile.with DEPENDENCY_NAME
      package :zip
      package :jar
    end
  end

  it "flattens nested arrays" do
    to_artifacts([["foo"]]).should eql(['foo']) 
  end

  it "turns projects into tasks to build projects" do
    artifacts = to_artifacts([@foo])
    artifacts.length.should eql(1)
    artifacts[0].should be_a_kind_of(Rake::Task)
    artifacts[0].to_s.should match(/foo-1\.1\.zip/)

    artifacts = to_artifacts([@bar])
    artifacts.length.should eql(2)
    artifacts.each do |artifact|
      artifact.should be_a_kind_of(Rake::Task)
      artifact.to_s.should match(/bar-1\.1\.(zip|jar)/)
    end
  end

  it "converts hashes into artifacts" do
    artifacts = to_artifacts([{:group => 'group', :id => 'id', :version => '1.0', :type => 'jar'}])
    artifacts.length.should eql(1)
    artifacts[0].should be_a_kind_of(Rake::Task)
    artifacts[0].to_s.should match(/group\/id\/1.0\/id-1\.0\.jar/)
  end

  protected

  def to_artifacts(args)
    Buildr::Bnd::BundleTask.to_artifacts(args)
  end
end
