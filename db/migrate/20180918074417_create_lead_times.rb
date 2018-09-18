class CreateLeadTimes < ActiveRecord::Migration[5.2]
  def change
    create_table :lead_times do |t|
      t.integer :min
      t.integer :max
      t.string :description

      t.timestamps
    end
  end
end
