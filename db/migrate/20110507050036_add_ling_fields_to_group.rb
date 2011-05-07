class AddLingFieldsToGroup < ActiveRecord::Migration
  def self.up
    change_table(:groups) {|t| t.text :ling_fields }
  end

  def self.down
    change_table(:groups) {|t| t.remove :ling_fields }
  end
end
