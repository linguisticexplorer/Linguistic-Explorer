require 'spec_helper'

describe Ling do
  it_should_validate_presence_of :name
  it_should_validate_uniqueness_of :name
  it_should_have_many :examples
end
