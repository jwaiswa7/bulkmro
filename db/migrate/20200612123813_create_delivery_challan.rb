class CreateDeliveryChallan < ActiveRecord::Migration[5.2]
  def change
    create_table :delivery_challans do |t|
      t.references :inquiry, foreign_key: true

      t.string :customer_request_attachment
      t.integer :goods_type
      t.text :reason

      t.timestamps
      t.userstamps
    end
  end
end
