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

      generate_csv(*@users)
      generate_csv(@group)
      generate_csv(*@lings)
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
  end
end
