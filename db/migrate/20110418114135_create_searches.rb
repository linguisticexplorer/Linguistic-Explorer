class CreateSearches < ActiveRecord::Migration
  def self.up
    create_table :searches, :force => true do |t|
      t.string  :name,      :null => false
      t.integer :user_id,   :null => false
      t.integer :group_id,  :null => false
      t.text    :query
      t.timestamps
    end

    add_index :searches, [:user_id, :group_id]
  end

  def self.down
    remove_index :searches, [:user_id, :group_id]
    drop_table :searches
  end
end