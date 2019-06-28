class CreateAclResources < ActiveRecord::Migration[5.2]
  def change
    create_table :acl_resources do |t|
      t.string :resource_model_name
      t.string :resource_action_name

      t.userstamps
      t.timestamps
    end
  end
end
