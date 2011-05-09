class AddGroupIdIndexesToGroupDataModels < ActiveRecord::Migration
  def self.up
    add_index :examples, :group_id
    add_index :examples, :ling_id
    add_index :examples_lings_properties, :group_id
    add_index :memberships, :group_id
    add_index :stored_values, :group_id
  end

  def self.down
    remove_index :stored_values, :group_id
    remove_index :memberships, :group_id
    remove_index :examples_lings_properties, :group_id
    remove_index :examples, :ling_id
    remove_index :examples, :group_id
  end
end