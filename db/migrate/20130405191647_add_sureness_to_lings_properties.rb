class AddSurenessToLingsProperties < ActiveRecord::Migration
  def self.up
    add_column :lings_properties, :sureness, :string
  end

  def self.down
    remove_column :lings_properties, :sureness
  end
end
