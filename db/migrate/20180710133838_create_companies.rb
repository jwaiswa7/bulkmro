class CreateCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :companies do |t|
      t.references :account, foreign_key: true
      t.references :industry, foreign_key: true

      t.integer :default_payment_option_id, index: true
      t.integer :default_billing_address, index: true
      t.integer :default_shipping_address, index: true
      t.string :name
      t.string :company_code
      t.boolean :is_strategic
      t.integer :default_payment_term

      t.string :phone
      t.string :mobile
      t.string :website
      t.string :company_type
      t.string :nature_of_business
#     t.integer :sales_person
#     t.integer :outside_sales_person
#     t.integer :sales_manager
      t.float :creditlimit
      t.string :tan
      t.string :pan
      t.string :central_excise_number
      t.string :msme
      t.string :urd
      t.integer :sap_create

      t.string :tax_identifier, index: { unique: true }

      t.timestamps
      t.userstamps
    end
    add_foreign_key :companies, :payment_options, column: :default_payment_option_id
    add_foreign_key :companies, :address, column: :default_billing_address
    add_foreign_key :companies, :address, column: :default_shipping_address

  end
end
