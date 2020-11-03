class RenameTableCompanySoTotalAmounts < ActiveRecord::Migration[5.2]
  def change
    rename_index :company_so_total_amounts, 'index_company_so_total_amounts_on_company_id_and_financial_year', 'index_company_transactions_on_company_id_and_financial_year'
    rename_column :company_so_total_amounts, :so_total_amount, :total_amount
    rename_table :company_so_total_amounts, :company_transactions_amounts
  end
end
