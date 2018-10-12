class CreateCurrencyRates < ActiveRecord::Migration[5.2]
  def change
    create_table :currency_rates do |t|
      t.references :currency, foreign_key: true

      t.date :logged_at
      t.decimal :conversion_rate

      t.timestamps
    end
  end
end
