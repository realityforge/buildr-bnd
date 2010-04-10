require File.expand_path('../../../spec_helper', __FILE__)

describe "project extension" do
  it "provides an 'bnd:print' task" do
    Rake::Task.tasks.detect{|task| task.to_s == "bnd:print"}.should_not be_nil
  end

  it "documents the 'bnd:print' task" do
    Rake::Task.tasks.detect{|task| task.to_s == "bnd:print"}.comment.should_not be_nil
  end
end
