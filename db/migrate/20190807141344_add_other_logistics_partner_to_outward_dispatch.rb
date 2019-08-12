class AddOtherLogisticsPartnerToOutwardDispatch < ActiveRecord::Migration[5.2]
  def change
    add_column :outward_dispatches, :logistics_partner_name, :string, default:nil
  end
end
