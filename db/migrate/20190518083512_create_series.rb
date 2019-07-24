class CreateSeries < ActiveRecord::Migration[5.2]
  def change
    create_table :series do |t|
      t.integer :document_type
      t.integer :series
      t.integer :number_length
      t.integer :first_number
      t.integer :last_number
      t.string :period_indicator
      t.string :series_name
      t.timestamps
    end
  end
end
