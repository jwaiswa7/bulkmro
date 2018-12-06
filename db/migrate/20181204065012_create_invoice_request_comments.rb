class CreateInvoiceRequestComments < ActiveRecord::Migration[5.2]
  def change
    create_table :invoice_request_comments do |t|
      t.references :invoice_request, foreign_key: true
      t.text :message

      t.userstamps
      t.timestamps
    end
  end
end
