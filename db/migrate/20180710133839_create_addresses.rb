class CreateAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :addresses do |t|
      t.references :address_state, foreign_key: true
      t.references :company, foreign_key: true
      t.string :remote_uid, index: { :unique => true }

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
      t.string :tan
      t.string :excise
      t.string :telephone
      t.string :mobile

      t.integer :gst_type

      t.timestamps
      t.userstamps
    end
  end
end
