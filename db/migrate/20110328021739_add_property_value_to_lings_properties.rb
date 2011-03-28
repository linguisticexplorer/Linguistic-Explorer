class AddPropertyValueToLingsProperties < ActiveRecord::Migration
  def self.up
    add_column :lings_properties, :property_value, :string

    add_index :lings_properties, :property_value
  end

  def self.down
    remove_index :lings_properties, :property_value

    remove_column :lings_properties, :property_value
  end
end