module CSVHelper

  def generate_csv_and_destroy_records(*models)
    base = models.first.class

    CSV.open("spec/csv/#{base.name}.csv", "wb") do |csv|
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

  def csv_row_count_should_equal_count_of(*models)
    # Add one to account for header row
    CSV.read("spec/csv/#{models.first.class.name}.csv").size.should == models.size + 1
  end


  def generate_group_data_csvs!
    # Create users
    @users = [].tap do |models|
      User::ACCESS_LEVELS.each do |al|
        models << Factory(:user, :name => "Bob #{al.capitalize}", :email => "bob#{al}@example.com",
                          :access_level => al, :password => "password_#{al}")
      end
    end
    @admin = @users.first
    @user = @users.last

    # Group
    @group = Factory(:group, :name => "SSWL", :privacy => Group::PRIVATE,
                     :depth_maximum => 1, :ling0_name => "Language", :ling1_name => "Speaker",
                     :property_name => "Grammar", :category_name => "Demographic",
                     :lings_property_name => "Value", :example_name => "Quotes",
                     :examples_lings_property_name => "Quote Values", :example_fields => "words, gloss")

    # Memberships
    @memberships = [].tap do |models|
      models << Factory(:membership, :group => @group, :member => @admin, :level => Membership::ADMIN, :creator => @admin)
      models << Factory(:membership, :group => @group, :member => @user, :level => Membership::MEMBER, :creator => @admin)
    end

    # Parent Lings
    @lings = [].tap do |models|
      2.times do |i|
        models << Factory(:ling, :group => @group, :name => "Parent #{i}", :depth => Depth::PARENT, :creator => @admin)
      end
    end

    # Child Lings
    @lings += [].tap do |models|
      @lings.each_with_index do |parent, i|
        models << Factory(:ling,
                          :group => @group, :name => "Child #{i}", :depth => Depth::CHILD, :creator => @admin, :parent => parent)
      end
    end

    # Categories
    @categories = [].tap do |models|
      {:parent => Depth::PARENT, :child => Depth::CHILD}.each do |k, depth|
        models << Factory(:category, :group => @group, :creator => @admin,
                          :name => "#{k.capitalize} Category", :depth => depth, :description=> "This is the #{k} category")
      end
    end

    # Examples, 1 for each ling
    @examples = [].tap do |models|
      @lings.each_with_index do |ling, i|
        models << Factory(:example, :ling => ling, :name => "Example #{i}", :group => @group, :creator => @admin)
      end
    end

    #
    @properties = [].tap do |models|
      @lings.each_with_index do |ling, i|
        models << Factory(:property, :name => "Property #{i}", :description => "This is property #{i}",
                          :group => @group, :creator => @admin, :category => @categories.detect { |c| c.depth == ling.depth })
      end
    end

    @lings_properties = [].tap do |models|
      @lings.each_with_index do |ling, i|
        models << Factory(:lings_property, :ling => ling, :property => @properties[i], :value => "Value #{i}",
                          :group => @group, :creator => @admin)
      end
    end

    @examples_lings_properties = [].tap do |models|
      @examples.each_with_index do |example, i|
        models << Factory(:examples_lings_property, :example => example,
                          :lings_property => @lings_properties[i], :group => @group, :creator => @admin)
      end
    end

    @stored_values = [].tap do |models|
      @examples.each do |example|
        models << Factory(:stored_value, :storable => example, :group => @group,
                          :key => "words", :value => "#{example.name} blah blah blah")
      end
      @examples.each do |example|
        models << Factory(:stored_value, :storable => example, :group => @group,
                          :key => "gloss", :value => "#{example.name} gloss")
      end
    end

    # Transfer model data to csv and destroy so we can test import of data
    @group_data = [@users, [@group], @memberships, @examples, @lings, @categories,
                   @properties, @lings_properties, @examples_lings_properties, @stored_values]

    @group_data.each do |models|
      generate_csv_and_destroy_records(*models)
    end

    return @group_data
  end

end