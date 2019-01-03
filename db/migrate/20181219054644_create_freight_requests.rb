class CreateFreightRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :freight_requests do |t|
      t.references :inquiry, foreign_key: true
      t.references :sales_order, foreign_key: true
      t.references :company, foreign_key: true
      t.references :sales_quote, foreign_key: true

      t.integer :supplier_id, index: true
      t.integer :pick_up_address_id, index: true
      t.integer :delivery_address_id, index: true
      t.integer :measurement
      t.integer :status
      t.integer :request_type
      t.integer :delivery_type
      t.integer :logistics_owner_id

      t.decimal :width
      t.decimal :length
      t.decimal :breadth
      t.decimal :height
      t.decimal :volumetric_weight

      t.string :attachments

      t.date :pick_up_date
      t.boolean :hazardous, default: false
      t.userstamps
      t.timestamps

    end

    add_foreign_key :freight_requests, :companies, column: :supplier_id
    add_foreign_key :freight_requests, :addresses, column: :pick_up_address_id
    add_foreign_key :freight_requests, :addresses, column: :delivery_address_id
    add_foreign_key :freight_requests, :overseers, column: :logistics_owner_id

  end
end
