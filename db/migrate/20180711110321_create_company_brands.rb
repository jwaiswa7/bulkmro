class CreateCompanyBrands < ActiveRecord::Migration[5.2]
  def change
    create_table :company_brands do |t|
      t.references :company, foreign_key: true
      t.references :brand, foreign_key: true

      t.timestamps
      t.userstamps
    end
    add_index :company_brands, [:company_id, :brand_id], unique: true
  end
end
