class CreateTargetPeriod < ActiveRecord::Migration[5.2]
  def change
    create_table :target_periods do |t|
      t.date :period_month

      t.timestamps
    end
  end
end
