class CreateExamplesLingsProperties < ActiveRecord::Migration
  def self.up
    create_table  :examples_lings_properties do |t|
      t.integer   :example_id
      t.integer   :lings_property_id
      t.integer   :creator_id
      t.integer   :group_id
      t.timestamps
    end
  end

  def self.down
    drop_table :examples_lings_properties
  end
end
