class AddDisplayStyleToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :display_style, :string, :default => "table"
  end

  def self.down
    remove_column :groups, :display_style
  end
end
