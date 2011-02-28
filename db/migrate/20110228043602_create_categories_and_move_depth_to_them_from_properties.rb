class CreateCategoriesAndMoveDepthToThemFromProperties < ActiveRecord::Migration
  # Note, does not migrate category data over

  def self.up
    create_table    :categories do |t|
      t.references  :group
      t.string      :name
      t.integer     :depth
      t.timestamps
    end

    change_table    :properties do |t|
      t.remove      :depth
      t.remove      :category
      t.references  :category
    end
  end

  def self.down
    change_table  :properties do |t|
      t.remove    :category_id
      t.integer   :depth
      t.string    :category
    end

    drop_table :categories
  end
end
