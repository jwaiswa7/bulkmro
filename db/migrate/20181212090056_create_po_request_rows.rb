class CreatePoRequestRows < ActiveRecord::Migration[5.2]
  def change
    create_table :po_request_rows do |t|
      t.references :po_request, foreign_key: true
      t.references :sales_order_row, foreign_key: true

      t.timestamps
    end
  end
end
