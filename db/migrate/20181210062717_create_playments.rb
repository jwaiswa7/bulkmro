class CreatePlayments < ActiveRecord::Migration[5.2]
  def change
    create_table :playments do |t|
      t.string :reference_id
      t.string :image_name
      t.string :image_url
      t.string :status
      t.string :request
      t.string :response
      t.string :meter_number
      t.string :meter_reading
      t.string :flu_id

      t.timestamps
    end
  end
end
