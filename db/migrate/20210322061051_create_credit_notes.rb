class CreateCreditNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :credit_notes do |t|
      t.references :sales_invoice, foreign_key: true
      t.integer :memo_number, index: { unique: true }
      t.datetime :memo_date
      t.decimal :memo_amount, default: 0.0
      t.timestamps
    end
  end
end
