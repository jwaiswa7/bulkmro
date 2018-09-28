class CreateActivities < ActiveRecord::Migration[5.2]
  def change
    create_table :activities do |t|
      t.references :inquiry, foreign_key: true
      t.references :company, foreign_key: true
      t.references :contact, foreign_key: true

      t.string :subject

      t.integer :company_type
      t.integer :purpose
      t.integer :activity_type

      t.text :points_discussed
      t.text :actions_required

      t.timestamps
      t.userstamps
    end
  end
end
