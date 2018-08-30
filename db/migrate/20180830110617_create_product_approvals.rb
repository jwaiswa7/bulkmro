class CreateProductApprovals < ActiveRecord::Migration[5.2]
  def change
    create_table :product_approvals do |t|
      t.references :product, foreign_key: true
      t.references :product_comment, foreign_key: true

      t.timestamps
      t.userstamps
    end
  end
end
