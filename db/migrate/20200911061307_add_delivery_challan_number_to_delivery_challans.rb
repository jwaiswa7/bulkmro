class AddDeliveryChallanNumberToDeliveryChallans < ActiveRecord::Migration[5.2]
  def change
    add_column :delivery_challans, :delivery_challan_number, :string
  end
end
