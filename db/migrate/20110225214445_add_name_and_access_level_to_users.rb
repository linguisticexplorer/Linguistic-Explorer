class AddNameAndAccessLevelToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string :name
      t.string :access_level
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :name
      t.remove :access_level
    end
  end
end
