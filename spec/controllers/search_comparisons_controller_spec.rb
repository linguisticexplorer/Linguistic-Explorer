require 'rails_helper'

describe SearchComparisonsController do
  before do
    @ability = Ability.new(nil)
    allow(@ability).to receive_message_chain(:can?).and_return true
    allow(@controller).to receive_message_chain(:current_ability).and_return(@ability)
  end

  describe "#new" do
    it "should authorize create on @search_comparison" do
      @group = groups(:inclusive)
      @sc = SearchComparison.new
      allow(SearchComparison).to receive_message_chain(:new).and_return @sc

      expect(@ability).to receive(:can?).with(:create, @sc).and_return true

      get :new, :group_id => @group.id
    end
  end

  describe "#create" do
    it "should authorize create on @search_comparison" do
      @group = groups(:inclusive)
      @sc = SearchComparison.new
      allow(@sc).to receive_message_chain(:search).and_return true
      allow(SearchComparison).to receive_message_chain(:new).and_return @sc

      expect(@ability).to receive(:can?).with(:create, @sc).and_return true

      get :create, :group_id => @group.id, :search_comparison => {}
    end
  end
end
