class CreateProductImports < ActiveRecord::Migration[5.2]
  def change
    create_table :product_imports do |t|
      t.references :overseer, foreign_key: true
      
      t.integer :import_type
      t.text :import_text
      
      t.timestamps
    end
  end
end
