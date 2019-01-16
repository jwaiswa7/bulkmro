class CreateActivityRejections < ActiveRecord::Migration[5.2]
  def change
    create_table :activity_rejections do |t|
      t.references :activity, foreign_key: true

      t.userstamps
      t.timestamps
    end
  end
end
