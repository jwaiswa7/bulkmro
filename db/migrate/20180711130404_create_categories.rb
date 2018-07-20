class CreateCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :categories do |t|
      t.integer :parent_id, index: true
      t.string :name

      t.timestamps
      t.userstamps
    end

    add_foreign_key :categories, :categories, column: :parent_id
  end
end
