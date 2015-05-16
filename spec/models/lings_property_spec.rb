require 'spec_helper'

describe LingsProperty do
  describe "one-liners" do
    it { expect validate_presence_of :ling }
    it { expect validate_presence_of :property }
    it { expect validate_presence_of :value }
    it { expect validate_presence_of :group }
    it { expect validate_uniqueness_of(:value).scoped_to(:ling_id, :property_id) }
    it { expect belong_to :ling }
    it { expect belong_to :property }
    it { expect belong_to :group }
    it { expect belong_to :creator }
    it { expect have_many :examples_lings_properties }
    it { expect have_many :examples }
  end

  describe "should be createable" do
    it "with a ling and property of the same depth and group" do
      group = groups(:inclusive)
      expect do
        LingsProperty.create(:ling_id => lings(:level0).id, :property_id => properties(:level0).id, :value => 'foo') do |lp|
          lp.group = group
        end
      end.to change(LingsProperty, :count).by(1)

      expect do
        LingsProperty.create(:ling_id => lings(:level1).id, :property_id => properties(:level1).id, :value => 'foo') do |lp|
          lp.group = group
        end
      end.to change(LingsProperty, :count).by(1)
    end

    it "only with lings and property of the same depth" do
      group = groups(:inclusive)
      LingsProperty.create(:ling_id => lings(:level0).id, :property_id => properties(:level1).id, :value => 'baz') do |lp|
        lp.group = group
      end.to have(1).errors

      LingsProperty.create(:ling_id => lings(:level1).id, :property_id => properties(:level0).id, :value => 'bar') do |lp|
        lp.group = group
      end.to have(1).errors
    end

    it "only with lings and property of the same group as the group_id" do
      group = groups(:inclusive)
      misgroup = groups(:exclusive)
      ling = lings(:level0)
      propEX = properties(:exclusive0)
      propINC = properties(:level0)

      LingsProperty.create(:ling_id => ling.id, :property_id => propEX.id, :value => 'group mismatch') do |lp|
        lp.group = group
      end.to have(1).errors

      LingsProperty.create(:ling_id => ling.id, :property_id => propEX.id, :value => 'group mismatch') do |lp|
        lp.group = misgroup
      end.to have(1).errors

      LingsProperty.create(:ling_id => ling.id, :property_id => propINC.id, :value => 'group mismatch') do |lp|
        lp.group = misgroup
      end.to have(1).errors
    end
  end

  describe "callbacks" do
    before(:each) do
      @ling  = lings(:level0)
      @prop  = properties(:level0)
      @group = groups(:inclusive)
      @lings_property = LingsProperty.create!(:ling => @ling, :property => @prop, :value => "foo", :group => @group)
    end

    describe "after_save" do
      it "should set property value column" do
        expect(@lings_property.property_value).to eq "#{@prop.id}:foo"
      end

      it "should update property value column if value changes" do
        @lings_property.update_attribute(:value, "bar")
        expect(@lings_property.property_value).to eq "#{@prop.id}:bar"
      end

      it "should update property value column if property changes" do
        new_property = properties(:valid)
        @lings_property.property = new_property
        @lings_property.save!
        expect(@lings_property.property_value).to eq "#{new_property.id}:foo"
      end
    end
  end

  describe "Getters" do
    before(:each) do
      @ling  = lings(:american_lang)
      @prop  = properties(:latlong)
      @group = groups(:geomap)
      @lings_property = LingsProperty.create!(:ling => @ling, :property => @prop, :value => "foo", :group => @group)
    end

    it "should retrieve the ling name capitalized" do
      expect(@lings_property.ling_name).to eq "#{@ling.name.capitalize}"
    end

    it "should have a description" do
      expect(@lings_property.description).to eq "#{@ling.name.capitalize} - #{@prop.name} : foo"
    end
  end
end
