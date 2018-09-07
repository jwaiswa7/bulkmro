class CreateInquiries < ActiveRecord::Migration[5.2]
  def change
    create_table :inquiries do |t|
      t.references :contact, foreign_key: true
      t.references :company, foreign_key: true

      t.integer :billing_address_id, index: true
      t.integer :shipping_address_id, index: true

      t.integer :insider_sales_owner_id, index: true
      t.integer :outside_sales_owner_id, index: true
      t.integer :sales_manager_id, index: true

      t.text :comments

      t.timestamps
      t.userstamps
    end

    add_foreign_key :inquiries, :overseers, column: :insider_sales_owner_id
    add_foreign_key :inquiries, :overseers, column: :outside_sales_owner_id
    add_foreign_key :inquiries, :overseers, column: :sales_manager_id
  end
end
