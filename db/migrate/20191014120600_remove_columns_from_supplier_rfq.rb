class RemoveColumnsFromSupplierRfq < ActiveRecord::Migration[5.2]
  def change
    remove_column :supplier_rfqs, :inquiry_product_id
    remove_column :supplier_rfqs, :product_id
  end
end
