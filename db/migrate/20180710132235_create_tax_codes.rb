class CreateTaxCodes < ActiveRecord::Migration[5.2]
  def change
    create_table :tax_codes do |t|
      t.integer :remote_uid, index: true
      t.integer :legacy_id, index: true

      t.string :code, index: true
      t.integer :chapter
      t.string :description, index: true

      t.boolean :is_service, default: false
      t.decimal :tax_percentage

      t.boolean :is_pre_gst, default: false

      t.jsonb :legacy_metadata
      t.timestamps
    end
  end
end