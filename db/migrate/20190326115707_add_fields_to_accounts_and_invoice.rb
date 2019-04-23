class AddFieldsToAccountsAndInvoice < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :opening_balance, :decimal, default: 0.0 unless column_exists? :accounts, :opening_balance
    add_column :companies, :opening_balance, :decimal, default: 0.0 unless column_exists? :companies, :opening_balance
    add_column :sales_invoices, :payment_status, :integer unless column_exists? :sales_invoices, :payment_status
    add_column :payment_options, :days, :integer unless column_exists? :payment_options, :days
  end
end
