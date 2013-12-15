class ExtendSearchResultsTextField < ActiveRecord::Migration
  def self.up
  	change_column :searches, :result_groups, :text, :limit => 16777215
  end
end
