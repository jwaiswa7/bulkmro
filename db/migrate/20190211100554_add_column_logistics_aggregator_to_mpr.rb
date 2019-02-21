class AddColumnLogisticsAggregatorToMpr < ActiveRecord::Migration[5.2]
  def change
    add_column :material_pickup_requests, :logistics_aggregator, :integer
  end
end
