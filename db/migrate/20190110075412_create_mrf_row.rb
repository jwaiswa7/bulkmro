class CreateMrfRow < ActiveRecord::Migration[5.2]
  def change
    create_table :mrf_rows do |t|
      t.references :material_readiness_followup, foreign_key: true
      t.references :purchase_order_row, foreign_key: true
      t.decimal :quantity
      t.string :status
    end
  end
end
