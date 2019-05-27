class AddIsSuperAdminToOverseer < ActiveRecord::Migration[5.2]
  def change
    add_column :overseers, :is_super_admin, :boolean
  end
end
