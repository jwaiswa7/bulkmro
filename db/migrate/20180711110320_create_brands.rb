class CreateBrands < ActiveRecord::Migration[5.2]
  def change
    create_table :brands do |t|
      t.string :name, index: { :unique => true }

      t.timestamps
      t.userstamps
    end
  end
end
