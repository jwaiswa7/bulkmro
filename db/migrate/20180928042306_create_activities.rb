class CreateActivities < ActiveRecord::Migration[5.2]
  def change
    create_table :activities do |t|
      t.references :inquiry, foreign_key: true
      t.references :company, foreign_key: true
      t.references :contact, foreign_key: true
      t.integer :legacy_id

      t.integer :activity_status
      t.string :subject
      t.string :reference_number

      t.integer :company_type
      t.integer :purpose
      t.integer :activity_type

      t.text :points_discussed
      t.text :actions_required

      t.jsonb :legacy_metadata
      t.timestamps
      t.userstamps
    end
  end
end
