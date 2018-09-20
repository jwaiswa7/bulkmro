class CreateBrands < ActiveRecord::Migration[5.2]
  def change
    create_table :brands do |t|
      t.integer :name, index: { :unique => true }
      t.integer :legacy_id

      t.timestamps
      t.userstamps
    end
  end
end
