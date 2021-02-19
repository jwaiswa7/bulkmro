class AddPurposeToDeliveryChallans < ActiveRecord::Migration[5.2]
  def change
    add_column :delivery_challans, :purpose, :integer
    add_column :delivery_challans, :other_reason, :text
    add_column :delivery_challans, :delivery_challan_date, :date
  end
end
