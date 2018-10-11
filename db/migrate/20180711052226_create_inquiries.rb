class CreateInquiries < ActiveRecord::Migration[5.2]
  def change
    create_table :inquiries do |t|
      t.references :contact, foreign_key: true
      t.references :company, foreign_key: true
      t.references :payment_option, foreign_key: true
      t.references :inquiry_currency, foreign_key: true, index: { unique: true }
      t.integer :billing_address_id, index: true
      t.integer :shipping_address_id, index: true
      t.integer :inside_sales_owner_id, index: true
      t.integer :outside_sales_owner_id, index: true
      t.integer :sales_manager_id, index: true
      t.integer :legacy_shipping_company_id, index: true
      t.integer :legacy_bill_to_contact_id, index: true

      t.integer :quotation_uid, index: { unique: true }
      t.integer :project_uid, index: { unique: true }
      t.integer :inquiry_number, index: { unique: true }
      t.integer :opportunity_uid, index: { unique: true }
      t.integer :legacy_id, index: true

      t.decimal :freight_cost

      t.string :legacy_contact_name
      t.string :subject
      t.string :customer_po_number
      t.string :customer_po_sheet
      t.string :calculation_sheet
      t.string :email_attachment
      t.string :supplier_quote_attachment
      t.string :supplier_quote_attachment_additional

      t.integer :bill_from_id, index: true
      t.integer :ship_from_id, index: true

      t.string :subject

      t.integer :opportunity_source
      t.integer :opportunity_type
      t.integer :status
      t.integer :stage
      t.integer :freight_option
      t.integer :packing_and_forwarding_option
      t.integer :quote_category
      t.integer :price_type
      t.integer :attachment_uid

      t.decimal :potential_amount, default: 0.00
      t.decimal :gross_profit_percentage, default: 0.00
      t.decimal :weight_in_kgs, default: 0.0
      t.decimal :priority, default: 0.0

      t.date :expected_closing_date
      t.date :quotation_date
      t.date :quotation_expected_date
      t.date :valid_end_time
      t.date :quotation_followup_date
      t.date :customer_order_date
      t.date :customer_committed_date
      t.date :procurement_date

      t.text :commercial_terms_and_conditions

      t.boolean :is_sez, default: false
      t.boolean :is_kit, default: false

      t.jsonb :legacy_metadata
      t.timestamps
      t.userstamps
    end
    add_foreign_key :inquiries, :overseers, column: :inside_sales_owner_id
    add_foreign_key :inquiries, :overseers, column: :outside_sales_owner_id
    add_foreign_key :inquiries, :overseers, column: :sales_manager_id

    add_foreign_key :inquiries, :companies, column: :legacy_shipping_company_id
    add_foreign_key :inquiries, :contacts, column: :legacy_bill_to_contact_id

    add_foreign_key :inquiries, :addresses, column: :billing_address_id
    add_foreign_key :inquiries, :addresses, column: :shipping_address_id
    add_foreign_key :inquiries, :warehouses, column: :bill_from_id
    add_foreign_key :inquiries, :warehouses, column: :ship_from_id
  end
end
