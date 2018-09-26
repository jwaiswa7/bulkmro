class CreateAddressStates < ActiveRecord::Migration[5.2]
  def change
    create_table :address_states do |t|

      t.integer :legacy_id

      t.integer :remote_uid, index: { unique: true }, null: true
      t.string :region_code_uid, index: true

      t.integer :legacy_id, index: true

      t.string :name, index: { unique: true }
      t.string :country_code
      t.string :region_code

      t.timestamps
    end
  end
end