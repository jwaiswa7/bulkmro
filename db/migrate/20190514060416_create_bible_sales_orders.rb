class CreateBibleSalesOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :bible_sales_orders do |t|
      t.integer "inquiry_number"
      t.string "order_number"
      t.string "inside_sales_owner"
      t.string 'company_name'
      t.string 'account_name'
      t.date 'client_order_date'
      t.date "mis_date"
      t.jsonb "metadata"
      t.string 'currency'
      t.float 'document_rate'
      t.boolean 'is_adjustment_entry'

      t.float 'order_total'
      t.float 'order_tax'
      t.float 'order_total_with_tax'
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "created_by_id"
      t.integer "updated_by_id"

      t.timestamps
      t.userstamps
    end
  end
end
