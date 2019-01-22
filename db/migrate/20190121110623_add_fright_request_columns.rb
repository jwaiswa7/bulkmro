class AddFrightRequestColumns < ActiveRecord::Migration[5.2]
  def change
    add_column :freight_requests, :material_type, :string
    add_column :freight_requests, :pickup_date, :date
    add_column :freight_requests, :loading, :integer
    add_column :freight_requests, :unloading, :integer
  end
end
