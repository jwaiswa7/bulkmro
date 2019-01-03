class AddColumnsToPoRequestRows < ActiveRecord::Migration[5.2]
  def change
    add_column :po_request_rows, :status, :integer
    add_column :po_request_rows, :quantity, :decimal
  end
end
