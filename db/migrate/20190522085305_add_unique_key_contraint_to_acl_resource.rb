class AddUniqueKeyContraintToAclResource < ActiveRecord::Migration[5.2]
  def change
    add_index :acl_resources, [:resource_model_name, :resource_action_name], unique: true, name: 'resource_model_action_index'
  end
end
