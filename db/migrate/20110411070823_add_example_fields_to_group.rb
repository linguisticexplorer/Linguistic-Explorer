class AddExampleFieldsToGroup < ActiveRecord::Migration
  def self.up
    change_table(:groups) {|t| t.text :example_fields }
  end

  def self.down
    change_table(:groups) {|t| t.remove :example_fields }
  end
end
