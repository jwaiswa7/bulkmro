class RenameColumnFromSupplierRfq < ActiveRecord::Migration[5.2]
  def change
    rename_column :supplier_rfqs, :inquiry_product_supplier_id, :supplier_id
    add_foreign_key :supplier_rfqs, :companies, column: :supplier_id
  end
end
