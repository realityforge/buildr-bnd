require File.expand_path('../../../spec_helper', __FILE__)

describe "package :bundle" do

  before do
    write "src/main/java/com/biz/Foo.java",<<SRC
package com.biz;
public class Foo {}
SRC
    @foo = define "foo" do
      project.version = "2.1.3"
      project.group = "bar"
      package :bundle
    end
    task('package').invoke

    @expected_jar_name = "target/foo-2.1.3.jar"
  end

  it "produces a .bnd in the correct location" do
    File.should be_exist(@foo._("target/foo-2.1.3.bnd"))
  end

  it "produces a .jar in the correct location" do
    File.should be_exist(@foo._(@expected_jar_name))
  end
end
