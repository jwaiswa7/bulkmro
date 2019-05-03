class AddIfscCodeReferenceToCompanyBanks < ActiveRecord::Migration[5.2]
  def change
    add_reference :company_banks, :ifsc_code, foreign_key: true
  end
end
