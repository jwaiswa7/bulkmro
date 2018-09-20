class CreateAddressStates < ActiveRecord::Migration[5.2]
  def change
    create_table :address_states do |t|
      t.string :name, index: { unique: true }

      t.string :country_code
      t.string :region_code
      t.string :region_gst_id
      t.string :region_id
      t.string :remote_uid
      t.timestamps
    end
  end
end
