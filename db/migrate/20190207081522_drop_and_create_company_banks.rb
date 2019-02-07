class DropAndCreateCompanyBanks < ActiveRecord::Migration[5.2]
  def change
    #   drop_table :company_banks
    remove_column :company_banks, :country_code if column_exists? :company_banks, :country_code

    remove_column :company_banks, :ifsc if column_exists? :company_banks, :ifsc

    remove_column :company_banks, :street_address if column_exists? :company_banks, :street_address

    remove_column :company_banks, :email if column_exists? :company_banks, :email

    remove_column :company_banks, :phone if column_exists? :company_banks, :phone

    remove_column :company_banks, :swift if column_exists? :company_banks, :swift

    remove_column :company_banks, :routing_number if column_exists? :company_banks, :routing_number

    remove_column :company_banks, :iban if column_exists? :company_banks, :iban

    add_reference :company_banks, :bank, foreign_key: true unless column_exists? :company_banks, :bank_id

    add_column :company_banks, :account_name, :string unless column_exists? :company_banks, :account_name

    add_column :company_banks, :account_number, :string unless column_exists? :company_banks, :account_number

    add_column :company_banks, :branch, :string unless column_exists? :company_banks, :branch

    add_column :company_banks, :address_line_1, :string unless column_exists? :company_banks, :address_line_1

    add_column :company_banks, :address_line_2, :string unless column_exists? :company_banks, :address_line_2

    add_column :company_banks, :beneficiary_email, :string unless column_exists? :company_banks, :beneficiary_email

    add_column :company_banks, :beneficiary_mobile, :string unless column_exists? :company_banks, :beneficiary_mobile

    add_column :company_banks, :remote_uid, :integer unless column_exists? :company_banks, :remote_uid

    add_column :company_banks, :metadata, :jsonb unless column_exists? :company_banks, :metadata

    add_column :company_banks, :mandate_id, :string unless column_exists? :company_banks, :mandate_id


  end
end
