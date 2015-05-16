require 'rails_helper'

describe Property do
  describe "one-liners" do
    it { expect validate_presence_of :name }
    it { expect validate_presence_of :category }
    it { expect validate_presence_of :group }
    it { expect validate_uniqueness_of(:name).scoped_to(:group_id) }
    it { expect belong_to :group}
    it { expect belong_to :creator }
    it { expect belong_to :category }
    it { expect have_many :lings_properties }
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
      expect(Property.create(:name => "misgrouped", :category_id => groups(:inclusive).categories.first.id) do |p|
          p.group = groups(:exclusive)
        end).to have(1).errors_on(:category)
    end
  end

  describe "#available_values" do
    it "should return an arrow of values from lings_properties related to itself" do
      prop = properties(:level0)
      lp = lings_properties(:level0)
      expect(prop.lings_properties).to include lp
      expect(prop.available_values).to include lp.value
    end
  end
end
