class CreateCurrencies < ActiveRecord::Migration[5.2]
  def change
    create_table :currencies do |t|
      t.integer :legacy_id, index: true
      t.string :name

      t.decimal :conversion_rate

      t.timestamps
    end
  end
end
