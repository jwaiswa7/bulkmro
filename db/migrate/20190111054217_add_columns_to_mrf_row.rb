class AddColumnsToMrfRow < ActiveRecord::Migration[5.2]
  def change
    add_column :mrf_rows, :pickup_quantity, :decimal
    add_column :mrf_rows, :delivered_quantity, :decimal
  end
end
