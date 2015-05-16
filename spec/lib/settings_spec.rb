require 'rails_helper'

describe Settings do

  describe "attr_accessor" do
    it "should allow class var to be set" do
      Settings.in_preview = true
      expect(Settings.in_preview).to be_truthy
    end
  end
  describe "configure" do
    it "should set defined class variable" do
      Settings.configure do |s|
        s.in_preview = true
      end
      expect(Settings.in_preview).to be_truthy
    end
  end
end
