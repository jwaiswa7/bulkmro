class AddLogisticsOwnerToCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :logistics_owner_id, :integer
  end
end
