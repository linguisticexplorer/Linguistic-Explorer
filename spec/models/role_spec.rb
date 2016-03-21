require 'rails_helper'

describe Role do
  
  describe "one-liners" do
    it { expect validate_presence_of :name }
    it { expect validate_inclusion_of(:name).in_array(Membership::ROLES) }
    it { expect belong_to :resource }
    it { expect belong_to :membership }
  end
end
