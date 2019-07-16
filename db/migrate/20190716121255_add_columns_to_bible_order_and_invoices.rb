class AddColumnsToBibleOrderAndInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :bible_sales_orders, :total_margin, :float, :default => 0
    add_column :bible_sales_orders, :inside_sales_owner_id, :integer
    add_column :bible_sales_orders, :outside_sales_owner_id, :integer
    add_column :bible_sales_orders, :overall_margin_percentage, :float, :default => 0
    add_reference :bible_sales_orders, :company, foreign_key: true
    add_reference :bible_sales_orders, :account, foreign_key: true
    add_reference :bible_sales_orders, :sales_order, foreign_key: true
    add_reference :bible_sales_orders, :sales_invoice, foreign_key: true

    add_foreign_key :bible_sales_orders, :overseers, column: :outside_sales_owner_id
    add_foreign_key :bible_sales_orders, :overseers, column: :inside_sales_owner_id

    remove_column :bible_sales_orders, :inside_sales_owner
    # remove_column :bible_sales_orders, :account_name



    add_reference :bible_invoices, :company, foreign_key: true
    add_reference :bible_invoices, :account, foreign_key: true
    add_column :bible_invoices, :overall_margin_percentage, :float, :default => 0

    add_reference :bible_invoices, :sales_invoice, foreign_key: true
    add_column :bible_invoices, :inside_sales_owner_id, :integer
    add_column :bible_invoices, :outside_sales_owner_id, :integer

    add_foreign_key :bible_invoices, :overseers, column: :outside_sales_owner_id
    add_foreign_key :bible_invoices, :overseers, column: :inside_sales_owner_id

    # add_reference :bible_invoices, :inquiry, foreign_key: true
    # add_reference :bible_sales_orders, :inquiry, foreign_key: true
    # add_foreign_key :bible_invoices, :inquiries, column: :inquiry_id
    # add_foreign_key :bible_sales_orders, :inquiries, column: :inquiry_id
  end
end
