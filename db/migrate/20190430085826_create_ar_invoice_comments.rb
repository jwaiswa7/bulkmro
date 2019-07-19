class CreateArInvoiceComments < ActiveRecord::Migration[5.2]
  def change
    create_table :ar_invoice_request_comments do |t|
      t.references :ar_invoice_request, foreign_key: true
      t.text :message

      t.userstamps
      t.timestamps
    end
  end
end
