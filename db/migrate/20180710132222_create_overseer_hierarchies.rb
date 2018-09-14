class CreateOverseerHierarchies < ActiveRecord::Migration[5.2]
  def change
    create_table :overseer_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :overseer_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name: "overseer_anc_desc_idx"

    add_index :overseer_hierarchies, [:descendant_id],
      name: "overseer_desc_idx"


    add_foreign_key :overseer_hierarchies, :overseers, :column => :ancestor_id
    add_foreign_key :overseer_hierarchies, :overseers, :column => :descendant_id
  end
end