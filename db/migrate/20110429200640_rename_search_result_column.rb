class RenameSearchResultColumn < ActiveRecord::Migration
  def self.up
    rename_column :searches, :result_rows, :result_groups
    
    remove_column :searches, :parent_ids
    remove_column :searches, :child_ids
  end

  def self.down
    add_column :searches, :child_ids, :text
    add_column :searches, :parent_ids, :text
    rename_column :searches, :result_groups, :result_rows
  end
end
