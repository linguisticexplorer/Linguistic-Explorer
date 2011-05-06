require 'spec_helper'

module GroupData

  describe Importer do
    before(:all) do

      # Create users
      @users = [].tap do |models|
        User::ACCESS_LEVELS.each do |al|
          models << Factory(:user, :name => "Bob #{al.capitalize}", :email => "bob#{al}@example.com",
            :access_level => al, :password => "password_#{al}")
        end
      end
      @admin  = @users.first
      @user   = @users.last

      @group  = Factory(:group, :name => "SSWL")

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

      @memberships = [].tap do |models|
        models << Factory(:membership, :group => @group, :member => @admin, :level => Membership::ADMIN, :creator => @admin)
        models << Factory(:membership, :group => @group, :member => @user, :level => Membership::MEMBER, :creator => @admin)
      end

      @categories = [].tap do |models|
        { :parent => Depth::PARENT, :child => Depth::CHILD }.each do |k, depth|
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

      # @stored_values = [].tap do |models|
      #   @examples.each do |example|
      #     models << Factory(:stored_value, :storable => @examples.first,
      #       :key => "words", :value => "#{example.name} blah blah blah")
      #   end
      # end

      generate_csv *@users
      generate_csv @group
      generate_csv *@memberships
      generate_csv *@examples
      generate_csv *@lings
      generate_csv *@categories
      generate_csv *@properties
      generate_csv *@lings_properties
      generate_csv *@examples_lings_properties
      # generate_csv *@stored_values
    end

    it "should have two users" do
      csv_row_count_should_equal_count_of(*@users)
    end

    it "should have a group" do
      csv_row_count_should_equal_count_of(@group)
    end

    it "should have four lings" do
      csv_row_count_should_equal_count_of(*@lings)
    end

    it "should have memberships" do
      csv_row_count_should_equal_count_of(*@memberships)
    end

    it "should have categories" do
      csv_row_count_should_equal_count_of(*@categories)
    end

    it "should have examples" do
      csv_row_count_should_equal_count_of(*@examples)
    end

    it "should have properties" do
      csv_row_count_should_equal_count_of(*@properties)
    end

    it "should have lings properties" do
      csv_row_count_should_equal_count_of(*@lings_properties)
    end

    it "should have lings properties" do
      csv_row_count_should_equal_count_of(*@examples_lings_properties)
    end

    # it "should have stored values" do
    #   csv_row_count_should_equal_count_of(*@stored_values)
    # end
  end
end
