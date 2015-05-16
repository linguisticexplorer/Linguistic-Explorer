require "spec_helper"

module SswlData

  describe Converter do

    before :each do
      @result = {}
    end

    describe "convert user success!" do
      before(:each) do
        @row = {
            "id" => 1,
            "first_name" => "John",
            "last_name" => "Doe",
            "email" => "john@doe.com",
            "user_type" => "admin"
        }
        Converter.convert_user_in(@row, @result)
      end

      it "should contain the row id" do
        expect(@result.keys).to eq [@row["id"]]
      end

      it "should contain all the values needed in Terraling" do
        expect(row_converted("id").keys).to eq ["id", "name", "email", "access_level", "password"]
      end

      it "should contain all string values" do
        row_converted("id").each {|k,v| expect(v.empty?).not_to be_truthy }
      end

      it "should convert the name in the right format" do
        expect(row_converted("id")["name"]).to eq "John Doe"
      end

      it "should convert the access level to the right format" do
        expect(row_converted("id")["access_level"]).to eq "admin"
      end

    end

    describe "convert membership success!" do
      before(:each) do
        @row = {
            "id" => 1,
            "user_type" => "admin"
        }
        Converter.convert_membership_in(@row, @result)
      end

      it "should contain the row id" do
        expect(@result.keys).to eq [@row["id"]]
      end

      it "should contain all the values needed in Terraling" do
        expect(row_converted("id").keys).to eq ["id", "member_id", "group_id", "level" ]
      end

      it "should contain all string values" do
        row_converted("id").each {|k,v| expect(v.empty?).not_to be_truthy }
      end

      it "should convert set same ID and Member ID " do
        expect(row_converted("id")["id"]).to eq @row["id"].to_s
        expect(row_converted("id")["member_id"]).to eq @row["id"].to_s
      end

      it "should convert the access level to the right format" do
        expect(row_converted("id")["level"]).to eq "admin"
      end

      it "should set the Group ID to 0" do
        expect(row_converted("id")["group_id"]).to eq "0"
      end

    end

    describe "convert ling success!" do
      before(:each) do
        @row = {
            "id" => 1,
            "language" => "English"
        }
        Converter.convert_ling_in(@row, @result)
      end

      it "should contain the language" do
        expect(@result.keys).to eq [@row["language"]]
      end

      it "should contain all the values needed in Terraling" do
        expect(row_converted("language").keys).to eq ["id", "name", "group_id", "depth" ]
      end

      it "should contain all string values" do
        row_converted("language").each {|k,v| expect(v.empty?).not_to be_truthy }
      end

      it "should set the Group ID to 0" do
        expect(row_converted("language")["group_id"]).to eq "0"
      end

      it "should set the Depth to 0" do
        expect(row_converted("language")["depth"]).to eq "0"
      end

    end

    describe "convert example success!" do
      before(:each) do
        @row = {
            "id" => 1,
            "language" => "English"
        }
        @ling_ids = { "English" => {"id" => 2 } }
        @counter = Converter.convert_example_in(@row, @result, @ling_ids, 0)
      end

      it "should contain the row id" do
        expect(@result.keys).to eq [@row["id"]]
      end

      it "should contain all the values needed in Terraling" do
        expect(row_converted("id").keys).to eq ["id", "name", "group_id", "ling_id" ]
      end

      it "should contain all string values" do
        row_converted("id").each {|k,v| expect(v.empty?).not_to be_truthy }
      end

      it "should set the Group ID to 0" do
        expect(row_converted("id")["group_id"]).to eq "0"
      end

      it "should set the Name to Example_0" do
        expect(row_converted("id")["name"]).to eq "Example_0"
      end

      it "should set the ID as foreign key to lings" do
        expect(row_converted("id")["ling_id"]).to eq @ling_ids[@row["language"]]["id"].to_s
      end

      it "should return 1" do
        expect(Converter.convert_example_in(@row, @result, @ling_ids, 0)).to eq 1
      end

    end

    describe "convert property success!" do
      before(:each) do
        @row = {
            "id" => 1,
            "property" => "Prop"
        }
        @counter = Converter.convert_property_in(@row, @result, 0)
      end

      it "should contain the row id" do
        expect(@result.keys).to eq [@row["property"]]
      end

      it "should contain all the values needed in Terraling" do
        expect(row_converted("property").keys).to eq ["id", "name", "group_id", "category_id", "description" ]
      end

      it "should contain all string values" do
        row_converted("property").each {|k,v| expect(v.empty?).not_to be_truthy }
      end

      it "should set the Group ID to 0" do
        expect(row_converted("property")["group_id"]).to eq "0"
      end

      it "should set the Category ID to 0" do
        expect(row_converted("property")["category_id"]).to eq "0"
      end

      it "should return as Name: Example_0" do
        expect(row_converted("property")["name"]).to eq "Prop"
      end

      it "should return 1" do
        expect(Converter.convert_property_in(@row, @result, 0)).to eq 1
      end

    end

    describe "convert ling property success!" do
      before(:each) do
        @row = {
            "id" => 1,
            "property" => "Prop",
            "language" => "English",
            "value" => "Yes"
        }
        @ling_ids = { "English" => {"id" => 2 } }
        @prop_ids = { "Prop" => {"id" => 3, "name" => "Prop" }}
        Converter.convert_ling_prop_in(@row, @result, @ling_ids, @prop_ids)
      end

      it "should contain the row id" do
        expect(@result.keys).to eq [ling_prop_key]
      end

      it "should contain all the values needed in Terraling" do
        expect(@result[ling_prop_key].keys).to eq ["id", "value", "group_id", "category_id", "property_id", "ling_id"]
      end

      it "should contain all string values" do
        @result[ling_prop_key].each {|k,v| expect(v.empty?).not_to be_truthy }
      end

      it "should set the Group ID to 0" do
        expect(@result[ling_prop_key]["group_id"]).to eq "0"
      end

      it "should set the Category ID to 0" do
        expect(@result[ling_prop_key]["category_id"]).to eq "0"
      end

      it "should return Yes" do
        expect(@result[ling_prop_key]["value"]).to eq "Yes"
      end

      it "should return the Property ID" do
        expect(@result[ling_prop_key]["property_id"]).to eq @prop_ids[@row["property"]]["id"].to_s
      end

      it "should return the Ling ID" do
        expect(@result[ling_prop_key]["ling_id"]).to eq @ling_ids[@row["language"]]["id"].to_s
      end

      def ling_prop_key
        "#{@row["language"]}:#{@prop_ids[@row["property"]]["name"]}:#{@row["value"]}"
      end

    end

    describe "convert store value success!" do
      before(:each) do
        @row = {
            "id" => 1,
            "property" => "Prop",
            "value" => "Yes",
            "example_object_id" => "test"
        }
        Converter.convert_stored_value_in(@row, @result)
      end

      it "should contain the row id" do
        expect(@result.keys).to eq [@row["id"]]
      end

      it "should contain all the values needed in Terraling" do
        expect(row_converted("id").keys).to eq ["id", "key", "value", "group_id", "storable_type", "storable_id" ]
      end

      it "should contain all string values" do
        row_converted("id").each {|k,v| expect(v.empty?).not_to be_truthy }
      end

      it "should set the Group ID to 0" do
        expect(row_converted("id")["group_id"]).to eq "0"
      end

      it "should set the Storable Type to Example" do
        expect(row_converted("id")["storable_type"]).to eq "Example"
      end

      it "should return Property name" do
        expect(row_converted("id")["key"]).to eq @row["property"]
      end

      it "should return a Property:Value string" do
        expect(row_converted("id")["value"]).to eq "#{@row["property"]}:#{@row["value"]}"
      end

      it "should return Example object ID" do
        expect(row_converted("id")["storable_id"]).to eq @row["example_object_id"]
      end

    end

    def row_converted(id)
      @result[@row[id]]
    end

  end
end