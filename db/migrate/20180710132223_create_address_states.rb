class CreateAddressStates < ActiveRecord::Migration[5.2]
  def change
    create_table :address_states do |t|
      t.string :name, index: { unique: true }

      t.string :country_code
      t.string :remote_code
      t.string :tax_state

      t.string :country_id, index: true
      t.string :region_code
      t.integer :region_id, index: true
      t.integer :region_gst_id, index: true
      t.string :remote_uid, index: { unique: true }

      t.timestamps
    end
  end
end
