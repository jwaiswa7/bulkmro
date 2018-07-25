class CreateSalesApprovals < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_approvals do |t|
      t.references :sales_quote, foreign_key: true
      t.text :comments

      t.timestamps
      t.userstamps
    end
  end
end
