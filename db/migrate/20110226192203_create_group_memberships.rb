class CreateGroupMemberships < ActiveRecord::Migration
  def self.up
    create_table    :group_memberships do |t|
      t.references  :user
      t.references  :group
      t.string      :level
      t.timestamps
    end
  end

  def self.down
    drop_table :group_memberships
  end
end
