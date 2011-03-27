require 'spec_helper'

describe Settings do

  describe "attr_accessor" do
    it "should allow class var to be set" do
      Settings.in_preview = true
      Settings.in_preview.should be_true
    end
  end
  describe "configure" do
    it "should set defined class variable" do
      Settings.configure do |s|
        s.in_preview = true
      end
      Settings.in_preview.should be_true
    end
  end
end
