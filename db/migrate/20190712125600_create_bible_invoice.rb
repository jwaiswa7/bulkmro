class CreateBibleInvoice < ActiveRecord::Migration[5.2]
  def change
    create_table :bible_invoices do |t|
      t.integer "branch_type"
      t.integer "inquiry_number"
      t.string "invoice_number"
      t.integer "invoice_type"
      t.string 'currency'
      t.float 'document_rate'
      t.date "mis_date"
      t.jsonb "metadata"
      t.boolean 'is_credit_note_entry'

      t.float 'invoice_total'
      t.float 'invoice_tax'
      t.float 'invoice_total_with_tax'
      t.float "total_margin"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "created_by_id"
      t.integer "updated_by_id"

      t.timestamps
      t.userstamps
    end
  end
end
