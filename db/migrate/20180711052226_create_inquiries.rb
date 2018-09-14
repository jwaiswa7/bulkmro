class CreateInquiries < ActiveRecord::Migration[5.2]
  def change
    create_table :inquiries do |t|
      t.references :contact, foreign_key: true
      t.references :company, foreign_key: true
      t.references :payment_option, foreign_key: true
      t.references :inquiry_currency, foreign_key: true, index: { unique: true }

      t.string :project_uid, index: { unique: true }
      t.string :opportunity_uid, index: { unique: true }

      t.integer :billing_address_id, index: true
      t.integer :shipping_address_id, index: true
      t.integer :inside_sales_owner_id, index: true
      t.integer :outside_sales_owner_id, index: true
      t.integer :sales_manager_id, index: true

      t.string :subject

      t.integer :opportunity_source
      t.integer :opportunity_type
      t.integer :status
      t.integer :stage
      t.integer :freight_option
      t.integer :packing_and_forwarding_option
      t.integer :quote_category
      t.integer :price_type

      t.decimal :potential_amount, default: 0.00
      t.decimal :gross_profit_percentage, default: 0.00
      t.decimal :weight_in_kgs, default: 0.0

      t.date :expected_closing_date

      t.text :commercial_terms_and_conditions
      t.text :comments

      t.timestamps
      t.userstamps
    end
    add_foreign_key :inquiries, :overseers, column: :inside_sales_owner_id
    add_foreign_key :inquiries, :overseers, column: :outside_sales_owner_id
    add_foreign_key :inquiries, :overseers, column: :sales_manager_id
  end
end
