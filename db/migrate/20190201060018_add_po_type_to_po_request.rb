class AddPoTypeToPoRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :po_requests, :supplier_po_type, :integer
  end
end
