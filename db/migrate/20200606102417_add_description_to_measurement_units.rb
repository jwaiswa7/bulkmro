class AddDescriptionToMeasurementUnits < ActiveRecord::Migration[5.2]
  def change
    add_column :measurement_units, :description, :string
  end
end
