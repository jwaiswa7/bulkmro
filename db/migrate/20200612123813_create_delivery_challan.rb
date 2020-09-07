class CreateDeliveryChallan < ActiveRecord::Migration[5.2]
  def change
    create_table :delivery_challans do |t|
      t.references :inquiry, foreign_key: true
      t.references :sales_order, foreign_key: true
      t.references :purchase_order, foreign_key: true
      t.references :ar_invoice_request, foreign_key: true

      t.integer :supplier_bill_from_id, index: true
      t.integer :supplier_ship_from_id, index: true
      t.integer :customer_bill_from_id, index: true
      t.integer :customer_ship_from_id, index: true
      t.integer :goods_type
      t.integer :reason

      t.date :customer_order_date
      t.date :sales_order_date

      t.string :customer_request_attachment

      t.timestamps
      t.userstamps
    end
  end
end
