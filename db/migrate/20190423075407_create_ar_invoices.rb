class CreateArInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :ar_invoice_requests do |t|
      t.integer :rejection_reason, :integer
      t.string  :other_rejection_reason
      t.integer :cancellation_reason
      t.string  :other_cancellation_reason
      t.boolean :e_way, :default => false


      t.integer :status
      t.integer :ar_invoice_number
      t.belongs_to :sales_order
      t.belongs_to :inquiry
      t.timestamps
      t.userstamps
    end
  end
end
