class CreateWarehouses < ActiveRecord::Migration[5.2]
  def change
    create_table :warehouses do |t|
      t.references :address, foreign_key: true
      t.string :legacy_id, index: true
      t.string :remote_uid, index: true

      t.jsonb :legacy_metadata

      t.boolean :is_visible, default: true

      t.string :name

      t.string :location_uid
      t.string :remote_branch_code
      t.string :remote_branch_name

      t.timestamps
    end
  end
end
