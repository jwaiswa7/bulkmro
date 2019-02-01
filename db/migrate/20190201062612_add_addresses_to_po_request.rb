class AddAddressesToPoRequest < ActiveRecord::Migration[5.2]
  def change
    add_reference :po_requests, :address, foreign_key: true
  end
end
