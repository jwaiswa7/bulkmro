class CreateLeadTimeOptions < ActiveRecord::Migration[5.2]
  def change
    create_table :lead_time_options do |t|
      t.integer :legacy_id, index: true

      t.integer :min_days
      t.integer :max_days
      t.string :name

      t.timestamps
    end
  end
end
