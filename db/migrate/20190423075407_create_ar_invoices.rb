class CreateArInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :ar_invoices do |t|
      t.integer :rejection_reason, :integer
      t.string  :other_rejection_reason
      t.integer :cancellation_reason
      t.string  :other_cancellation_reason

      t.integer :status
      t.integer :ar_invoice_number
      t.belongs_to :sales_order
      t.timestamps
      t.userstamps
    end
  end
end
