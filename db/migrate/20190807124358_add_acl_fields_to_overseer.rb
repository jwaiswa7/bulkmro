class AddAclFieldsToOverseer < ActiveRecord::Migration[5.2]
  def change
    add_column :overseers, :acl_updated_at, :datetime
    add_column :overseers, :acl_updated_by, :integer, null: true, index: true

    add_foreign_key :overseers, :overseers, column: :acl_updated_by
  end
end
