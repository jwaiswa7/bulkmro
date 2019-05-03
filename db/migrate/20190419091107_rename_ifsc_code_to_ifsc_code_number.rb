class RenameIfscCodeToIfscCodeNumber < ActiveRecord::Migration[5.2]
  def change
    rename_column :company_banks, :ifsc_code, :ifsc_code_number
  end
end
