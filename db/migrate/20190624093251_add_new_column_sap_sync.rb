class AddNewColumnSapSync < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_orders, :sap_sync, :integer, default: 10
  end
end
