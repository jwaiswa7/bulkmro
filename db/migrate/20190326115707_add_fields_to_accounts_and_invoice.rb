class AddFieldsToAccountsAndInvoice < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :opening_balance, :decimal, default: 0.0
    add_column :companies, :opening_balance, :decimal, default: 0.0
    add_column :sales_invoices, :payment_status, :integer
    add_column :payment_options, :days, :integer
  end
end
