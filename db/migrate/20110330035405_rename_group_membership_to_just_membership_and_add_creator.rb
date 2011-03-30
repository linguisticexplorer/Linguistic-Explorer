class RenameGroupMembershipToJustMembershipAndAddCreator < ActiveRecord::Migration
  def self.up
    rename_table :group_memberships, :memberships
    change_table(:memberships) do |t|
      t.integer :creator_id
    end
  end

  def self.down
    change_table(:memberships) do |t|
      t.remove :creator_id
    end
    rename_table :memberships, :group_memberships
  end
end
