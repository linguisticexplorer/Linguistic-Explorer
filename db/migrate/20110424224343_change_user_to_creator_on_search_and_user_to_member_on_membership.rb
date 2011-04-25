class ChangeUserToCreatorOnSearchAndUserToMemberOnMembership < ActiveRecord::Migration
  def self.up
    remove_index :searches, [:user_id, :group_id]

    rename_column :searches, :user_id, :creator_id
    rename_column :memberships, :user_id, :member_id

    add_index :searches, [:creator_id, :group_id]
  end

  def self.down
    remove_index :searches, [:creator_id, :group_id]

    rename_column :searches, :creator_id, :user_id
    rename_column :memberships, :member_id, :user_id

    add_index :searches, [:user_id, :group_id]
  end
end
