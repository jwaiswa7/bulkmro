class CreateFreightQuoteComments < ActiveRecord::Migration[5.2]
  def change
    create_table :freight_quote_comments do |t|
      t.references :freight_quote, foreign_key: true
      t.text :message

      t.userstamps
      t.timestamps
    end
  end
end
