module CSVHelper

  def generate_csv_and_destroy_records(*models)
    base = models.first.class

    CSV.open("spec/csv/good/#{base.name}.csv", "wb") do |csv|
      # header row
      cols = base::CSV_ATTRIBUTES
      csv << cols

      # data rows
      models.each do |model|
        csv << cols.map { |attribute| model.send(attribute) }
      end
    end

    models.map { |m| m.destroy }
  end

  def generate_bad_csv_from_good_ones!(dir)
    files = File.join(Rails.root.join("spec", "csv", "good"), "*.csv")
    Dir.glob(files).each do |file|
      FileUtils.cp(file, Rails.root.join("spec", "csv", "bad", dir, file.gsub(/.*good\//, "")))
    end
    files = File.join(Rails.root.join("spec", "csv", "bad", dir), "*.csv")
    generate_bad_csv_no_id!(files) if dir=="no_id"
    generate_bad_csv_foreign_key!(files) if dir=="bad_foreign_key"
    generate_bad_csv_creator_id!(files) if dir=="bad_creator_id"
  end

  def generate_bad_csv_no_id!(files)
    generate_bad_csvs(files) do |content, row|
      new_row = row.to_hash
      new_row["id"] = nil if new_row["id"].present?
      content << new_row
    end
  end

  def generate_bad_csv_foreign_key!(files)
    generate_bad_csvs(files) do |content, row|
      new_row = row.to_hash
      new_row["group_id"] = "-1" if new_row["group_id"].present?
      content << new_row
    end
  end

  def generate_bad_csv_creator_id!(files)
    generate_bad_csvs(files) do |content, row|
      new_row = row.to_hash
      new_row["creator_id"] = "-1" if new_row["creator_id"].present?
      content << new_row
    end
  end

  def csv_row_count_should_equal_count_of(*models)
    # Add one to account for header row
    CSV.read("spec/csv/good/#{models.first.class.name}.csv").size.should == models.size + 1
  end

  def generate_group_data_csvs!
    # Create users
    @users = [].tap do |models|
      User::ACCESS_LEVELS.each do |al|
        models << FactoryGirl.create(:user, :name => "Bob #{al.capitalize}", :email => "bob#{al}@example.com",
                          :access_level => al, :password => "password_#{al}")
      end
    end
    @admin = @users.first
    @user = @users.last

    # Group
    @group = FactoryGirl.create(:group, :name => "SSWL", :privacy => Group::PRIVATE,
                     :depth_maximum => 1, :ling0_name => "Language", :ling1_name => "Speaker",
                     :property_name => "Grammar", :category_name => "Demographic",
                     :lings_property_name => "Value", :example_name => "Quotes",
                     :examples_lings_property_name => "Quote Values", :example_fields => "words, gloss")

    # Memberships
    @memberships = [].tap do |models|
      models << FactoryGirl.create(:membership, :group => @group, :member => @admin, :level => Membership::ADMIN, :creator => @admin)
      models << FactoryGirl.create(:membership, :group => @group, :member => @user, :level => Membership::MEMBER, :creator => @admin)
    end

    # Parent Lings
    @lings = [].tap do |models|
      2.times do |i|
        models << FactoryGirl.create(:ling, :group => @group, :name => "Parent #{i}", :depth => Depth::PARENT, :creator => @admin)
      end
    end

    # Child Lings
    @lings += [].tap do |models|
      @lings.each_with_index do |parent, i|
        models << FactoryGirl.create(:ling,
                          :group => @group, :name => "Child #{i}", :depth => Depth::CHILD, :creator => @admin, :parent => parent)
      end
    end

    # Categories
    @categories = [].tap do |models|
      {:parent => Depth::PARENT, :child => Depth::CHILD}.each do |k, depth|
        models << FactoryGirl.create(:category, :group => @group, :creator => @admin,
                          :name => "#{k.capitalize} Category", :depth => depth, :description=> "This is the #{k} category")
      end
    end

    # Examples, 1 for each ling
    @examples = [].tap do |models|
      @lings.each_with_index do |ling, i|
        models << FactoryGirl.create(:example, :ling => ling, :name => "Example #{i}", :group => @group, :creator => @admin)
      end
    end

    #
    @properties = [].tap do |models|
      @lings.each_with_index do |ling, i|
        models << FactoryGirl.create(:property, :name => "Property #{i}", :description => "This is property #{i}",
                          :group => @group, :creator => @admin, :category => @categories.detect { |c| c.depth == ling.depth })
      end
    end

    @lings_properties = [].tap do |models|
      @lings.each_with_index do |ling, i|
        models << FactoryGirl.create(:lings_property, :ling => ling, :property => @properties[i], :value => "Value #{i}",
                          :group => @group, :creator => @admin)
      end
    end

    @examples_lings_properties = [].tap do |models|
      @examples.each_with_index do |example, i|
        models << FactoryGirl.create(:examples_lings_property, :example => example,
                          :lings_property => @lings_properties[i], :group => @group, :creator => @admin)
      end
    end

    @stored_values = [].tap do |models|
      @examples.each do |example|
        models << FactoryGirl.create(:stored_value, :storable => example, :group => @group,
                          :key => "words", :value => "#{example.name} blah blah blah")
      end
      @examples.each do |example|
        models << FactoryGirl.create(:stored_value, :storable => example, :group => @group,
                          :key => "gloss", :value => "#{example.name} gloss")
      end
    end

    # Transfer model data to csv and destroy so we can test import of data
    @group_data = [@users, [@group], @memberships, @examples, @lings, @categories,
                   @properties, @lings_properties, @examples_lings_properties, @stored_values]

    @group_data.each do |models|
      generate_csv_and_destroy_records(*models)
    end
  end

  def generate_bad_csvs(files)
    Dir.glob(files).each do |file|
      content = []
      header = (CSV.read file).shift
      CSV.foreach(file, :headers => true) do |row|
        yield(content, row)
      end

      CSV.open(file, "wb") do |csv|
        csv << header
        content.each do |row|
          csv <<  header.map {|attribute| row[attribute]}
        end
      end
    end
  end

end