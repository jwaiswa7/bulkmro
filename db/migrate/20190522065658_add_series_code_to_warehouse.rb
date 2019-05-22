class AddSeriesCodeToWarehouse < ActiveRecord::Migration[5.2]
  def change
    add_column :Warehouse, :series_code, :integer
  end
end