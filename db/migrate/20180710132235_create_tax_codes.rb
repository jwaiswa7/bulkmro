class CreateTaxCodes < ActiveRecord::Migration[5.2]
  def change
    create_table :tax_codes do |t|
      t.integer :remote_uid, index: { unique: true }

      t.integer :chapter
      t.string :code, index: { unique: true }
      t.string :description, index: true

      t.boolean :is_service
      t.decimal :tax_percentage

      t.timestamps
    end
  end
end
