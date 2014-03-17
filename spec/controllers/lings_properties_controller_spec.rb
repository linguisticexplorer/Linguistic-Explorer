require 'spec_helper'

describe LingsPropertiesController do
  before do
    @ability = Ability.new(nil)
    @ability.stub(:can?).and_return true
    @controller.stub(:current_ability).and_return(@ability)
  end

  describe "show" do
    describe "assigns" do
      it "@lings_property should match the passed id" do
        get :show, :id => lings_properties(:smelly), :group_id => groups(:inclusive).id
        assigns(:lings_property).should == lings_properties(:smelly)
      end
    end

    it "@lings_property should be found by id through current_group" do
      @lp = lings_properties(:level0)
      @group = @lp.group
      Group.stub(:find).and_return(Group)

      Group.should_receive(:lings_properties).and_return @group.lings_properties

      get :show, :id => @lp.id, :group_id => @group.id
    end
  end

  describe "destroy" do
    def do_destroy_on_lings_property(lp)
      delete :destroy, :group_id => lp.group.id, :id => lp.id
    end

    before do
      @lp = lings_properties(:inclusive)
      @group = @lp.group
    end

    it "should authorize :destroy on the passed lings_property" do
      @ability.should_receive(:can?).ordered.with(:destroy, @lp).and_return(true)
      Group.stub(:find).and_return(@group)

      do_destroy_on_lings_property(@lp)
    end

    it "loads the lings_property through current group" do
      @group.should_receive(:lings_properties).and_return LingsProperty.where(:group_id => @group.id)
      Group.stub(:find).and_return @group

      do_destroy_on_lings_property(@lp)
    end

    it "calls destroy on the requested lings_property" do
      @group.stub(:lings_properties).and_return LingsProperty

      @lp.should_receive(:destroy).and_return(true)

      LingsProperty.stub(:find).and_return @lp
      Group.stub(:find).and_return @group
      do_destroy_on_lings_property(@lp)
    end
    
    # TODO: change this to go back to the ling page once destroyed
    it "redirects to the group home page" do
      @group = groups(:inclusive)
      delete :destroy, :id => lings_properties(:inclusive), :group_id => @group.id
      response.should redirect_to(@group)
    end
  end
end
