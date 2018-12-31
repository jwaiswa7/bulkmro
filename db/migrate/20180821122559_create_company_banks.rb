class CreateCompanyBanks < ActiveRecord::Migration[5.2]
  def change
    create_table :company_banks do |t|
      t.references :company, foreign_key: true
      t.string :country
      t.string :name
      t.string :code
      t.string :account_name
      t.string :account_number, index: { unique: true }
      t.string :branch
      t.string :ifsc_code
      t.string :address_line_1
      t.string :address_line_2
      t.string :beneficiary_email
      t.string :beneficiary_mobile
      t.string :remote_uid

      t.timestamps
    end
  end
end
