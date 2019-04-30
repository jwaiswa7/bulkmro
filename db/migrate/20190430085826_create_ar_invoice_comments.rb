class CreateArInvoiceComments < ActiveRecord::Migration[5.2]
  def change
    create_table :ar_invoice_comments do |t|
      t.references :ar_invoice, foreign_key: true
      t.text :message

      t.userstamps
      t.timestamps
    end
  end
end
