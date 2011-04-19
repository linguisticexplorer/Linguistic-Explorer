class AddSerializedIdsToSearches < ActiveRecord::Migration
  def self.up
    add_column :searches, :parent_ids,  :text
    add_column :searches, :child_ids,   :text
  end

  def self.down
    remove_column :searches, :child_ids
    remove_column :searches, :parent_ids
  end
end