class AddFieldsToAclResources < ActiveRecord::Migration[5.2]
  def change
    add_column :acl_resources, :is_menu_item, :boolean, :null => false, :default => false
    add_column :acl_resources, :sort_order, :integer
    add_column :acl_resources, :resource_action_alias, :string
    add_column :acl_resources, :resource_model_alias, :string
  end
end