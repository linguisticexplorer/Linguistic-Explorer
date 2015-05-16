require 'spec_helper'

describe Property do
  describe "one-liners" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :category }
    it { should validate_presence_of :group }
    it { should validate_uniqueness_of(:name).scoped_to(:group_id) }
    it { should belong_to :group}
    it { should belong_to :creator }
    it { should belong_to :category }
    it { should have_many :lings_properties }
    # it_should_validate_presence_of :name, :category, :group
    # it_should_validate_uniqueness_of :name, :scope => :group_id

    # it_should_belong_to :group, :creator, :category
    # it_should_have_many :lings_properties
  end

  describe "should be createable" do
    it "with a category" do
      expect do
        Property.create(:name => "depth 0", :category_id => groups(:inclusive).categories.first.id) do |p|
          p.group = groups(:inclusive)
        end
      end.to change(Property, :count).by(1)
    end

    it "unless category does not belong to the same group" do
      expect do
        Property.create(:name => "misgrouped", :category_id => groups(:inclusive).categories.first.id) do |p|
          p.group = groups(:exclusive)
        end
      end.to have(1).errors_on(:category)
    end
  end

  describe "#available_values" do
    it "should return an arrow of values from lings_properties related to itself" do
      prop = properties(:level0)
      lp = lings_properties(:level0)
      prop.lings_properties.to include lp
      prop.available_values.to include lp.value
    end
  end
end
