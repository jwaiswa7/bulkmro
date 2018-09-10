class CreateAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :addresses do |t|
      t.references :address_state, foreign_key: true
      t.references :company, foreign_key: true

      t.string :country_code
      t.string :name
      t.string :state_name
      t.string :city_name
      t.string :pincode
      t.string :street1
      t.string :street2      
      t.string :gst_no
      t.string :cst_no
      t.string :vat_no
      t.string :tan_no
      t.string :excise_no
      t.string :phone
      t.integer :gst_type # Hardcoded on in the System
      t.integer :sap_id, index: { :unique => true }

      t.timestamps
      t.userstamps
    end
  end
end
