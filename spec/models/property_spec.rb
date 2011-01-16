require 'spec_helper'

describe Property do
  it_should_validate_presence_of :name, :category
end
