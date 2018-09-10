class CreateInquiries < ActiveRecord::Migration[5.2]
  def change
    create_table :inquiries do |t|
      t.references :contact, foreign_key: true
      t.references :company, foreign_key: true

      t.integer :billing_address_id, index: true
      t.integer :shipping_address_id, index: true

      t.string :status
      t.string :opportunity_type
      t.decimal :potential_amount, default: 0.00
      t.string :opportunity_source
      t.string :subject
      t.string :internal_status
      t.decimal :gross_profit, default: 0.00
      t.datetime :expected_closing_date

      t.integer :insider_sales_owner_id, index: true
      t.integer :outside_sales_owner_id, index: true
      t.integer :sales_manager_id, index: true
      
      t.string :quote_category
      t.string :price
      t.string :freight
      t.decimal :freight_cost, default: 0.00
      t.string :packing_and_forwarding
      t.decimal :weight
      t.integer :payment_option_id, index: true
      t.text :commercial_terms_and_conditions
      t.text :comments

      t.timestamps
      t.userstamps
    end

    add_foreign_key :inquiries, :overseers, column: :insider_sales_owner_id
    add_foreign_key :inquiries, :overseers, column: :outside_sales_owner_id
    add_foreign_key :inquiries, :overseers, column: :sales_manager_id
    add_foreign_key :inquiries, :payment_options, column: :payment_option_id
  end
end
