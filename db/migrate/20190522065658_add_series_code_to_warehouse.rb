class AddSeriesCodeToWarehouse < ActiveRecord::Migration[5.2]
  def change
    add_column :warehouses, :series_code, :integer
  end
end