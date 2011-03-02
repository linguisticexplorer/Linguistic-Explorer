class AddOptionsToGroup < ActiveRecord::Migration
  def self.up
    change_table  :groups do |t|
      t.string    :ling0_name
      t.string    :ling1_name
      t.string    :property_name
      t.string    :category_name
      t.string    :lings_property_name
      t.string    :example_name
      t.string    :example_lp_name

      t.integer   :depth_maximum
      t.string    :privacy
    end
  end

  def self.down
    change_table  :groups do |t|
      t.remove    :ling0_name
      t.remove    :ling1_name
      t.remove    :property_name
      t.remove    :category_name
      t.remove    :lings_property_name
      t.remove    :example_name
      t.remove    :example_lp_name

      t.remove    :depth_maximum
      t.remove    :privacy
    end
  end
end
