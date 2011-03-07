class AddGroupIndexes < ActiveRecord::Migration
  def self.up
    add_index :lings, :group_id
    add_index :properties, :group_id
    add_index :categories, :group_id
    
    add_index :lings_properties, :group_id
    add_index :lings_properties, [:ling_id, :property_id]
  end

  def self.down
    remove_index :lings_properties, [:ling_id, :property_id]
    remove_index :lings_properties, :group_id
    
    remove_index :categories, :group_id
    remove_index :properties, :group_id
    remove_index :lings, :group_id
  end
end