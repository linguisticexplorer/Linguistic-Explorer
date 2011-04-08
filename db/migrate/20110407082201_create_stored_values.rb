class CreateStoredValues < ActiveRecord::Migration
  def self.up
    create_table :stored_values do |t|
      t.string  :key
      t.string  :value
      t.integer :storable_id
      t.string  :storable_type
      t.integer :group_id
      t.timestamps
    end
  end

  def self.down
    drop_table :stored_values
  end
end
