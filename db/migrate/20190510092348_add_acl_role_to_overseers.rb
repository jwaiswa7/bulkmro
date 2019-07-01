class AddAclRoleToOverseers < ActiveRecord::Migration[5.2]
  def change
    add_reference :overseers, :acl_role, foreign_key: true
  end
end
