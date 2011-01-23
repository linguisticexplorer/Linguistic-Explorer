class CreateExamples < ActiveRecord::Migration
  def self.up
    create_table  :examples do |t|
      t.integer   :ling_id
      t.string    :name
      t.timestamps
    end
  end

  def self.down
    drop_table :examples
  end
end
