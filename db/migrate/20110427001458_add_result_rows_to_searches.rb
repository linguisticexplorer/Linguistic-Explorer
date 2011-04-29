class AddResultRowsToSearches < ActiveRecord::Migration
  def self.up
    add_column :searches, :result_rows, :text
  end

  def self.down
    remove_column :searches, :result_rows
  end
end