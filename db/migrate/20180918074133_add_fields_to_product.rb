class AddFieldsToProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :unit_of_measurement, :string
  end
end
