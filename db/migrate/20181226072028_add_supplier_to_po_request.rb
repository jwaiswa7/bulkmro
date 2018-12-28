class AddSupplierToPoRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :po_requests, :supplier_id, :integer, index: true

    add_foreign_key :po_requests, :companies, column: :supplier_id
  end
end
