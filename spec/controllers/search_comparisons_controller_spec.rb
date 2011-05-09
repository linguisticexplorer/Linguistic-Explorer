require 'spec_helper'

describe SearchComparisonsController do
  before do
    @ability = Ability.new(nil)
    @ability.stub(:can?).and_return true
    @controller.stub(:current_ability).and_return(@ability)
  end

  describe "#new" do
    it "should authorize create on @search_comparison" do
      @group = groups(:inclusive)
      @sc = SearchComparison.new
      SearchComparison.stub(:new).and_return @sc

      @ability.should_receive(:can?).with(:create, @sc).and_return true

      get :new, :group_id => @group.id
    end
  end

  describe "#create" do
    it "should authorize create on @search_comparison" do
      @group = groups(:inclusive)
      @sc = SearchComparison.new
      @sc.stub(:search).and_return true
      SearchComparison.stub(:new).and_return @sc

      @ability.should_receive(:can?).with(:create, @sc).and_return true

      get :create, :group_id => @group.id, :search_comparison => {}
    end
  end
end
