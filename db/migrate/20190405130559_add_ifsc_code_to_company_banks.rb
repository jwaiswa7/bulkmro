class AddIfscCodeToCompanyBanks < ActiveRecord::Migration[5.2]
  def change
    add_column :company_banks, :ifsc_code, :string
  end
end
