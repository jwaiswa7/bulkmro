class AddDefaultCurrencyToCompanies < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :default_currency, :string
  end
end
