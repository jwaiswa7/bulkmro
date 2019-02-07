class DropAndCreateCompanyBanks < ActiveRecord::Migration[5.2]
  def change
    drop_table :company_banks
    create_table :company_banks do |t|
      t.references :company, foreign_key: true
      t.references :bank, foreign_key: true
      t.string :account_name
      t.string :account_number
      t.string :branch
      t.string :address_line_1
      t.string :address_line_2
      t.string :beneficiary_email
      t.string :beneficiary_mobile
      t.integer :remote_uid
      t.jsonb :metadata
      t.string :mandate_id

      t.timestamps
    end
  end
end
