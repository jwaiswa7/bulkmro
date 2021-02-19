class AddColumnsToDeliveryChallans < ActiveRecord::Migration[5.2]
  def change
    add_column :delivery_challans, :display_gst_pan, :boolean
    add_column :delivery_challans, :display_rates, :boolean
    add_column :delivery_challans, :display_stamp, :boolean
  end
end
