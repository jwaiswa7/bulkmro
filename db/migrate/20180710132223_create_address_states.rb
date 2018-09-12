class CreateAddressStates < ActiveRecord::Migration[5.2]
  def change
    create_table :address_states do |t|
      t.string :name, index: { unique: true }

      t.string :country_code
      t.string :remote_code
      t.string :tax_state

      t.timestamps
    end
  end
end
