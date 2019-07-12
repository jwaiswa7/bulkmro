class AddReferencesToBibleInvoices < ActiveRecord::Migration[5.2]
  def change
    add_reference :bible_invoices, :company, foreign_key: true
    add_reference :bible_invoices, :account, foreign_key: true
    # add_reference :bible_invoices, :sales_order, foreign_key: true
    add_reference :bible_invoices, :sales_invoice, foreign_key: true
    add_column :bible_invoices, :inside_sales_owner_id, :integer
    add_column :bible_invoices, :outside_sales_owner_id, :integer

    add_foreign_key :bible_invoices, :overseers, column: :outside_sales_owner_id
    add_foreign_key :bible_invoices, :overseers, column: :inside_sales_owner_id

  end
end
