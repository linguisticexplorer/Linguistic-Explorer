class CreateGroupsAndAddGroupIdFieldToTheWorld < ActiveRecord::Migration
  @@modified_tables = [:lings, :properties, :lings_properties, :examples]
  def self.up
    create_table :groups do |t|
      t.string :name
      t.timestamps
    end

    @@modified_tables.each do |table_name|
      change_table table_name do |t|
        t.integer :group_id
      end
    end
  end

  def self.down
    @@modified_tables.each do |table_name|
      change_table table_name do |t|
        t.remove :group_id
      end
    end
    drop_table :groups
  end
end
