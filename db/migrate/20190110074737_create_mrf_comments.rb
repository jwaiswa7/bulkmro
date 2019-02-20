class CreateMrfComments < ActiveRecord::Migration[5.2]
  def change
    create_table :mrf_comments do |t|
      t.references :material_readiness_followup, foreign_key: true
      t.text :message

      t.userstamps
      t.timestamps
    end
  end
end
