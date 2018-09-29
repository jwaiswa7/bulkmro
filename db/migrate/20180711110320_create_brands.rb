class CreateBrands < ActiveRecord::Migration[5.2]
  def change
    create_table :brands do |t|
      t.string :name, index: { :unique => true }
      t.integer :legacy_id

      t.jsonb :legacy_metadata

      t.timestamps
      t.userstamps
    end
  end
end
