class CreateCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :companies do |t|
      t.references :account, foreign_key: true
      t.references :industry, foreign_key: true

      t.integer :default_contact_id, index: true
      t.integer :default_payment_option_id, index: true
      t.integer :default_billing_address_id, index: true
      t.integer :default_shipping_address_id, index: true
      t.integer :inside_sales_owner_id, index: true
      t.integer :outside_sales_owner_id, index: true
      t.integer :sales_manager_id, index: true

      t.string :name, index: true
      t.integer :company_type
      t.string :remote_uid, index: { unique: true }
      t.integer :priority
      t.string :site
      t.integer :nature_of_business

      t.decimal :credit_limit
      t.string :tan_proof
      t.string :pan_proof
      t.string :cen_proof
      t.boolean :is_msme, default: false
      t.boolean :is_unregistered_dealer, default: false

      t.string :tax_identifier, index: { unique: true }

      t.timestamps
      t.userstamps
    end
    add_foreign_key :companies, :payment_options, column: :default_payment_option_id


    add_foreign_key :companies, :overseers, column: :inside_sales_owner_id
    add_foreign_key :companies, :overseers, column: :outside_sales_owner_id
    add_foreign_key :companies, :overseers, column: :sales_manager_id
  end
end
