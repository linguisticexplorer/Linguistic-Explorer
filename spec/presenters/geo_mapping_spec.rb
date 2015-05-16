require "spec_helper"

describe GeoMapping do

  # before(:each) do
  #   @ling_1 = lings(:american_lang)
  #   @ling_2 = lings(:african_lang)
  #   @property = properties(:latlong)
  #   @property_copy = properties(:latlong_support)
  #   @cat = categories(:geomap_cat).id
  # end

  # describe "json for regular search results" do

  #   before (:each) do
  #     query = create_mock_query(@ling_1.depth.to_s, "#{@cat}", "any")
  #     query["lings"] = { @ling_1.depth.to_s => [@ling_1.id.to_s]}
  #     query["include"] = { "ling_0" => "1"}
  #     @search = do_search(query)
  #   end

  #   it "should be json string" do
  #     json = "{\"type\":\"Regular\",\"data\":{\"#{@ling_1.id.to_s}\":[\"1\",\"\"]}}"
  #     expect(GeoMapping.new(@search).to_json).to eq(json)
  #   end

  # end

  # describe "json for cross search results" do
  #   before (:each) do
  #     [lings_properties(:american_prop_lang), lings_properties(:african_prop_lang),
  #      lings_properties(:american_prop_lang_support), lings_properties(:african_prop_lang_support)].each {|lp| lp.save!}

  #     query = create_mock_query(@ling_1.depth.to_s, "#{@cat}", "cross")
  #     query["properties"] = { "#{@cat}" => ["#{@property.id}", "#{@property_copy.id}"] }
  #     query["lings"] = { @ling_1.depth.to_s => [@ling_1.id.to_s]}
  #     @search = do_search(query)
  #   end
  #   it "should be json string" do
  #     json = "{\"type\":\"Cross\",\"data\":{\"#{@ling_1.id.to_s}\":[\"1\",\"\"]}}"
  #     expect(GeoMapping.new(@search).to_json).to eq(json)
  #   end
  # end

  # describe "json for compare search results" do
  #   before (:each) do

  #     query = create_mock_query(@ling_1.depth.to_s, "#{@cat}", "any")
  #     query["ling_set"] = { @ling_1.depth.to_s => "compare" }
  #     query["lings"] = { @ling_1.depth.to_s => [ @ling_1.id.to_s, @ling_2.id.to_s]}
  #     @search = do_search(query)
  #   end

  #   it "should be json string" do
  #     json = "{\"type\":\"Compare\",\"data\":{\"#{@ling_1.id.to_s}\":[\"1\",\"\"],\"#{@ling_2.id.to_s}\":[\"maybe\",\"\"]}}"
  #     expect(GeoMapping.new(@search).to_json).to eq(json)
  #   end
  # end

  # def do_search(query)
  #   Search.new do |s|
  #     s.creator = nil
  #     s.group = groups(:geomap)
  #     s.query = query
  #   end
  # end

  # def create_mock_query(ling_depth, category_id, search_type)
  #   { "ling_keywords"=>{ ling_depth =>""}, "property_keywords"=>{category_id=>""}, "example_keywords"=>{ ling_depth =>""}, "lings_property_set" => {category_id => "any"}, "property_set"=>{category_id=>search_type}}
  # end
end
