class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.references :brand, foreign_key: true
      t.string :name
      t.string :sku, index: { unique: true }

      t.timestamps
      t.userstamps
    end
  end
end
