class AddGstToAddressState < ActiveRecord::Migration[5.2]
  def change
    add_column :address_states, :gst_code, :string
  end
end
