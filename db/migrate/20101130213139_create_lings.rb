class CreateLings < ActiveRecord::Migration
  def self.up
    create_table  :lings do |t|
      t.string    :name
      t.timestamps
    end
  end

  def self.down
    drop_table :lings
  end
end
