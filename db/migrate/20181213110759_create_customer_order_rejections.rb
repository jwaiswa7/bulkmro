class CreateCustomerOrderRejections < ActiveRecord::Migration[5.2]
  def change
    create_table :customer_order_rejections do |t|
      t.references :customer_order, foreign_key: true

      t.jsonb :metadata

      t.timestamps
      t.userstamps(:contacts)
    end
  end
end
