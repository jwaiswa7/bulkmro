class AddIsStrategicToCompanies < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :is_strategic, :boolean, default: false
  end
end
