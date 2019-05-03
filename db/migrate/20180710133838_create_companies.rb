class CreateCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :companies do |t|
      t.references :account, foreign_key: true
      t.references :industry, foreign_key: true

      t.string :remote_uid, index: {unique: true}
      t.integer :legacy_id, index: true
      t.integer :attachment_uid, index: true

      t.integer :default_company_contact_id, index: true
      t.integer :default_payment_option_id, index: true
      t.integer :default_billing_address_id, index: true
      t.integer :default_shipping_address_id, index: true
      t.integer :inside_sales_owner_id, index: true
      t.integer :outside_sales_owner_id, index: true
      t.integer :sales_manager_id, index: true

      t.string :name, index: true
      t.string :site
      t.string :phone
      t.string :mobile
      t.string :legacy_email

      t.string :pan
      t.string :tan

      t.integer :company_type
      t.integer :priority
      t.integer :nature_of_business

      t.decimal :credit_limit
      t.boolean :is_msme, default: false
      t.boolean :is_unregistered_dealer, default: false
      t.boolean :is_supplier, default: false
      t.boolean :is_customer, default: true

      t.string :tax_identifier, index: {unique: true}

      t.jsonb :legacy_metadata
      t.timestamps
      t.userstamps
    end
    add_foreign_key :companies, :payment_options, column: :default_payment_option_id
    add_foreign_key :companies, :overseers, column: :inside_sales_owner_id
    add_foreign_key :companies, :overseers, column: :outside_sales_owner_id
    add_foreign_key :companies, :overseers, column: :sales_manager_id
  end
end
