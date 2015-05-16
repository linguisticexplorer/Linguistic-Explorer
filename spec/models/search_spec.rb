require 'rails_helper'

describe Search do

  describe "validations" do
    before(:each) do
      allow(Search).to receive_message_chain(:reached_max_limit?).and_return(false)
      @user  = User.new
      @group = Group.new
      @search = Search.new do |s|
        s.creator  = @user
        s.group = @group
      end
    end

    it { expect validate_presence_of :group }
    it { expect validate_presence_of :creator }
    it { expect validate_presence_of :name }

    it "should validate user within max search limit" do
      allow(Search).to receive_message_chain(:reached_max_limit?).and_return(true)
      @search.valid?
      expect(@search).to have(1).error_on(:base)
    end
  end

  describe "query" do
    before(:each) do
      builder = SearchResults::SearchFilterBuilder
      allow(builder).to receive_message_chain(:new).and_return(double(builder, :filtered_parent_and_child_ids => [[], []]))
      @search = FactoryGirl.create(:search)
    end

    it "should serialize query params" do
      @search.query = {"lings" => [1,2,3], "properties"=> [4,5,6] }
      @search.save

      retrieved = Search.find @search.id

      expect(retrieved.query).to eq({"lings"=> [1,2,3], "properties" => [4,5,6]})
    end
  end

  describe "reached_max_limit?" do
    before(:each) do
      allow(Search).to receive_message_chain(:scoped).and_return(Search)
      allow(Search).to receive_message_chain(:count).and_return(0)
      @user = double(User)
      @group = double(Group)
    end

    it "should perform count conditions where user is user and group is group" do
      expect(Search).to receive(:by).with(@user).and_return(Search)
      expect(Search).to receive(:in_group).with(@group).and_return(Search)
      expect(Search).to receive(:count)
      Search.reached_max_limit?(@user, @group)
    end

    it "should return true if count for searches by user and group has reached max limit" do
      allow(Search).to receive_message_chain(:by).and_return(Search)
      allow(Search).to receive_message_chain(:in_group).and_return(Search)

      allow(Search).to receive_message_chain(:count).and_return(25)
      expect(Search.reached_max_limit?(@user, @group)).to be_truthy
      allow(Search).to receive_message_chain(:count).and_return(26)
      expect(Search.reached_max_limit?(@user, @group)).to be_truthy
    end

    it "should return true if count for searches by user and group has reached max limit" do
      allow(Search).to receive_message_chain(:by).and_return(Search)
      allow(Search).to receive_message_chain(:in_group).and_return(Search)
      allow(Search).to receive_message_chain(:count).and_return(24)
      expect(Search.reached_max_limit?(@user, @group)).to be_falsey
    end
  end

  describe "is_manageable_by?" do
    before(:each) do
      @user  = User.new
      @group = Group.new

      @search = Search.new do |s|
        s.creator  = @user
        s.group = @group
      end
    end
    describe "anonymous_user" do
      it "should be false" do
        expect(@search.is_manageable_by?(@user)).to be_falsey
      end
    end

    describe "search is new_record" do
      before(:each) do
        @creator = User.last || FactoryGirl.create(:user, :email => "bob-searcher@example.com")
        @search.creator = @creator
        @ability = double(Ability, :can? => true)
        allow(Ability).to receive_message_chain(:new).and_return(@ability)
      end

      it "should be false if user is not creator" do
        expect(@search.is_manageable_by?(FactoryGirl.create(:user))).to be_falsey
      end

      describe "user is creator" do
        it "should be true if user has group access" do
          allow(@ability).to receive_message_chain(:can?).and_return(true)
          expect(@search.is_manageable_by?(@creator)).to be_truthy
        end
        it "should be false if no group access" do
          allow(@ability).to receive_message_chain(:can?).and_return(false)
          expect(@search.is_manageable_by?(@creator)).to be_falsey
        end

      end
    end
  end

  describe "search type" do
    before(:each) do
      @ling_1 = lings(:american_lang)
      @ling_2 = lings(:african_lang)
      @property = properties(:latlong)
      @property_support = properties(:latlong_support)
      @cat = categories(:geomap_cat).id
    end

    it "should be default search" do
      expect(create_default_search.default?).to be_truthy
    end

    it "should be cross search" do
      expect(create_cross_search.cross?).to be_truthy
    end

    it "should be compare search" do
      expect(create_compare_search.compare?).to be_truthy
    end

    it "should not be default search" do
      expect(create_cross_search.default?).to be_falsey
    end

    it "should not be cross search" do
      expect(create_compare_search.cross?).to be_falsey
    end

    it "should be a mapable search" do
      expect(create_compare_search.mappable?).to be_truthy
    end
  end

  def process_search(query)
    Search.new do |s|
      s.creator = nil
      s.group = groups(:geomap)
      s.query = query
    end
  end

  def create_mock_query(ling_depth, category_id, search_type)
    { "ling_keywords"=>{ ling_depth =>""}, "property_keywords"=>{category_id=>""}, "example_keywords"=>{ ling_depth =>""}, "lings_property_set" => {category_id => "any"}, "property_set"=>{category_id=>search_type}}
  end

  def create_compare_search
    query = create_mock_query(@ling_1.depth.to_s, "#{@cat}", "any")
    query["ling_set"] = { @ling_1.depth.to_s => "compare" }
    query["lings"] = { @ling_1.depth.to_s => [ @ling_1.id.to_s, @ling_2.id.to_s]}
    process_search(query)
  end

  def create_cross_search
    query = create_mock_query(@ling_1.depth.to_s, "#{@cat}", "cross")
    query["properties"] = {"#{@cat}" => ["#{@property.id}", "#{@property_support.id}"]}
    query["lings"] = {@ling_1.depth.to_s => [@ling_1.id.to_s]}
    process_search(query)
  end

  def create_default_search
    query = create_mock_query(@ling_1.depth.to_s, "#{@cat}", "any")
    query["lings"] = {@ling_1.depth.to_s => [@ling_1.id.to_s]}
    query["include"] = {"ling_0" => "1"}
    process_search(query)
  end
end
