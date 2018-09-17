class CreateSalesOrderApprovals < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_order_approvals do |t|
      t.references :sales_order, foreign_key: true
      t.references :inquiry_comment, foreign_key: true

      t.jsonb :metadata

      t.userstamps
      t.timestamps
    end
  end
end
