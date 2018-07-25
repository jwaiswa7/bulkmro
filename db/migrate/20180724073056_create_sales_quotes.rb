class CreateSalesQuotes < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_quotes do |t|
      t.references :inquiry, foreign_key: true

      t.integer :billing_address_id, index: true
      t.integer :shipping_address_id, index: true

      t.text :comments

      t.timestamps
      t.userstamps
    end
  end
end
