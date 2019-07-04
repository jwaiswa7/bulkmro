class AddAclResourcesToOverseers < ActiveRecord::Migration[5.2]
  def change
    add_column :overseers, :acl_resources, :jsonb
  end
end
