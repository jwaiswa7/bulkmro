class CreatePackingSlipRows < ActiveRecord::Migration[5.2]
  def change
    create_table :packing_slip_rows do |t|
      t.belongs_to :packing_slip
      t.belongs_to :ar_invoice_request_row
      t.string :sku
      t.decimal :quantity_stocked
      t.decimal :delivery_quantity
      t.timestamps
    end
  end
end
