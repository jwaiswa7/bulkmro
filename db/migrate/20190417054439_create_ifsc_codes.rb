class CreateIfscCodes < ActiveRecord::Migration[5.2]
  def change
    create_table :ifsc_codes do |t|
      t.string :ifsc_code
      t.string :branch
      t.text :address
      t.string :city
      t.string :district
      t.string :state
      t.string :contact
      t.references :bank, foreign_key: true

      t.timestamps
    end
  end
end
