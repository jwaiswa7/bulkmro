class CreateCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :categories do |t|
      t.references :tax_code, foreign_key: true
      t.integer :parent_id, index: true
      t.integer :remote_uid, index: true
      t.integer :legacy_id, index:true, required: true

      t.string :name
      t.string :description

      t.timestamps
      t.userstamps
    end

    add_foreign_key :categories, :categories, column: :parent_id
  end
end
