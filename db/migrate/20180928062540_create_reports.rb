class CreateReports < ActiveRecord::Migration[5.2]
  def change
    create_table :reports do |t|
      t.string :name, index: { unique: true }
      t.string :uid, index: { unique: true }

      t.datetime :start_at
      t.datetime :end_at
      t.integer :date_range

      t.timestamps
    end
  end
end
