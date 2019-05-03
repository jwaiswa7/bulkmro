class CreateAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :addresses do |t|
      t.references :address_state, foreign_key: true
      t.references :company, foreign_key: true
      t.integer :legacy_id, index: true
      t.string :remote_uid, index: true

      t.integer :billing_address_uid, index: true
      t.integer :shipping_address_uid, index: true

      t.string :country_code
      t.string :name
      t.string :state_name
      t.string :city_name
      t.string :pincode
      t.string :street1
      t.string :street2

      t.string :gst
      t.string :cst
      t.string :vat

      t.string :excise
      t.string :telephone
      t.string :mobile
      t.boolean :is_sez, default: false
      t.integer :gst_type

      t.jsonb :legacy_metadata
      t.timestamps
      t.userstamps
    end
  end
end
