class CreateInquiryCurrencies < ActiveRecord::Migration[5.2]
  def change
    create_table :inquiry_currencies do |t|
      t.references :currency, foreign_key: true

      t.decimal :conversion_rate


      t.timestamps
    end
  end
end
