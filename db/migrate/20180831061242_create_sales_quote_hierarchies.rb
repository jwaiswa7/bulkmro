class CreateSalesQuoteHierarchies < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_quote_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :sales_quote_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name: "sales_quote_anc_desc_idx"

    add_index :sales_quote_hierarchies, [:descendant_id],
      name: "sales_quote_desc_idx"
  end
end
