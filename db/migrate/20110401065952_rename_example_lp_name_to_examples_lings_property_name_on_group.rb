class RenameExampleLpNameToExamplesLingsPropertyNameOnGroup < ActiveRecord::Migration
  def self.up
    rename_column(:groups, :example_lp_name, :examples_lings_property_name)
  end

  def self.down
    rename_column(:groups, :examples_lings_property_name, :example_lp_name)
  end
end
