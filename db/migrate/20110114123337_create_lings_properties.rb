class CreateLingsProperties < ActiveRecord::Migration
  def self.up
    create_table  :lings_properties do |t|
      t.integer   :ling_id
      t.integer   :property_id
      t.string    :value
      t.timestamps
    end
  end

  def self.down
    drop_table :lings_properties
  end
end
