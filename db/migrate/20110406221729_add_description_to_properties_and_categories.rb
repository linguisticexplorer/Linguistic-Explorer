class AddDescriptionToPropertiesAndCategories < ActiveRecord::Migration
  def self.up
    [:properties, :categories].each{|name| change_table(name) {|t| t.text :description }}
  end

  def self.down
    [:properties, :categories].each{|name| change_table(name) {|t| t.remove :description }}
  end
end
