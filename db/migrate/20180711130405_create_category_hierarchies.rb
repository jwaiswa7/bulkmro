class CreateCategoryHierarchies < ActiveRecord::Migration[5.2]
  def change
    create_table :category_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :category_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name: "category_anc_desc_idx"

    add_index :category_hierarchies, [:descendant_id],
      name: "category_desc_idx"

    add_foreign_key :category_hierarchies, :categories, :column => :ancestor_id
    add_foreign_key :category_hierarchies, :categories, :column => :descendant_id
  end
end
