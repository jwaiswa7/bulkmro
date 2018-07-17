class CreateBrands < ActiveRecord::Migration[5.2]
  def change
    create_table :brands do |t|
      t.references :company, foreign_key: true
      t.string :name

      t.timestamps
      t.userstamps
    end
  end
end
