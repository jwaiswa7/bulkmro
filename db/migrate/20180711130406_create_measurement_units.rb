class CreateMeasurementUnits < ActiveRecord::Migration[5.2]
  def change
    create_table :measurement_units do |t|
      t.integer :legacy_id, index: true
      t.string :name, index: { unique: true }

      t.timestamps
    end
  end
end
