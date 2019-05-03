class AddWeightToFreightRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :freight_requests, :weight, :decimal
  end
end
