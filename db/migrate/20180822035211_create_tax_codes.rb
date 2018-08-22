class CreateTaxCodes < ActiveRecord::Migration[5.2]
  def change
    create_table :tax_codes do |t|
      t.string :code, index: { unique: true }
      t.string :description

      t.timestamps
    end
  end
end
