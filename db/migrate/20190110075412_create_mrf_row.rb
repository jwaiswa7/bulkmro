class CreateMrfRow < ActiveRecord::Migration[5.2]
  def change
    create_table :mrf_rows do |t|
      t.references :material_readiness_followup, foreign_key: true
      t.references :purchase_order_row, foreign_key: true
      t.string :status
      t.decimal :pickup_quantity
      t.decimal :delivered_quantity

      t.timestamps

      add_index :mrf_rows, [:material_readiness_followup_id, :purchase_order_row_id], unique: true, name: 'index_mrfr_on_mrf_and_por'
    end
  end
end
