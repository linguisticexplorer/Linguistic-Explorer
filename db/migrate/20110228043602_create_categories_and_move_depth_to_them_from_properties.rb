class CreateCategoriesAndMoveDepthToThemFromProperties < ActiveRecord::Migration
  # Note, does not migrate category data over

  def self.up
    create_table    :categories do |t|
      t.references  :group
      t.string      :name
      t.integer     :depth
      t.timestamps
    end

    change_table  :properties do |t|
      t.remove    :depth
      t.integer   :category
    end
  end

  def self.down
    change_table  :properties do |t|
      t.integer   :depth
      t.remove    :category
    end

    drop_table :categories
  end
end
