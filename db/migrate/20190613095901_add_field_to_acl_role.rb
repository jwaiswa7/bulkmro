class AddFieldToAclRole < ActiveRecord::Migration[5.2]
  def change
    add_column :acl_roles, :is_default, :boolean
  end
end
