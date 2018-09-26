class AddPanTanToCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :pan, :string
    add_column :companies, :tan, :string
  end
end
