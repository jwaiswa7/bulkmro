class CreateSupplierRfqs < ActiveRecord::Migration[5.2]
  def change
    create_table :supplier_rfqs do |t|

      t.references :inquiry, foreign_key: true
      t.references :inquiry_product_supplier, foreign_key: true
      t.references :inquiry_product, foreign_key: true
      t.references :product, foreign_key: true
      t.integer :status
      t.datetime :email_sent_at

      t.timestamps
      t.userstamps
    end
  end
end
