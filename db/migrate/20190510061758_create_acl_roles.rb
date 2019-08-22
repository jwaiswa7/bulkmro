class CreateAclRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :acl_roles do |t|
      t.string :role_name
      t.jsonb :role_resources

      t.userstamps
      t.timestamps
    end
  end
end
