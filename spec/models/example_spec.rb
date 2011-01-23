require 'spec_helper'

describe Example do
  it_should_be_createable :with => {:ling_id => 1234, :name => 'example-with-ling_id'}
  it_should_be_createable :with => {:name => 'example-without-ling_id'}
  it_should_belong_to :ling
  #it should probably validate attributes when those come in
end
