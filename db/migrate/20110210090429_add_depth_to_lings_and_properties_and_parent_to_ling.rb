class AddDepthToLingsAndPropertiesAndParentToLing < ActiveRecord::Migration
  def self.up
    change_table :lings do |t|
      t.integer :depth
      t.integer :parent_id
    end

    change_table :properties do |t|
      t.integer :depth
    end
  end

  def self.down
    change_table :lings do |t|
      t.remove :depth
      t.remove :parent_id
    end

    change_table :properties do |t|
      t.remove :depth
    end
  end
end
