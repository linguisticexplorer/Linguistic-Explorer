class AddCreatorIdToAllLinguisticData < ActiveRecord::Migration
  @@modified_tables = [:lings, :properties, :lings_properties, :examples, :categories]

  def self.up
    @@modified_tables.each do |table_name|
      change_table table_name do |t|
        t.integer :creator_id
      end
    end
  end

  def self.down
    @@modified_tables.each do |table_name|
      change_table table_name do |t|
        t.remove :creator_id
      end
    end
  end
end
