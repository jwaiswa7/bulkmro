class CreateSalesQuotes < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_quotes do |t|
      t.references :inquiry, foreign_key: true
      t.integer :parent_id, index: true
      t.integer :legacy_id, index: true

      t.datetime :sent_at

      t.timestamps
      t.userstamps
    end

    add_foreign_key :sales_quotes, :sales_quotes, column: :parent_id
  end
end
