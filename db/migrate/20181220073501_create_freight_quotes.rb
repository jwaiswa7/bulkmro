class CreateFreightQuotes < ActiveRecord::Migration[5.2]
  def change
    create_table :freight_quotes do |t|
      t.references :freight_request, foreign_key: true
      t.string :attachments
      t.integer :status
      t.integer :logistics_owner_id

      t.decimal :invoice_value

      t.userstamps
      t.timestamps
    end

    add_foreign_key :freight_quotes, :overseers, column: :logistics_owner_id
  end
end
