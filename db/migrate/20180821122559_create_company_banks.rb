class CreateCompanyBanks < ActiveRecord::Migration[5.2]
  def change
    create_table :company_banks do |t|
      t.references :company, foreign_key: true
      t.string :country_code
      t.string :account_number, index: { unique: true }
      t.string :ifsc
      t.string :street_address
      t.string :email
      t.string :phone
      t.string :swift
      t.string :routing_number
      t.string :iban

      t.timestamps
    end
  end
end
