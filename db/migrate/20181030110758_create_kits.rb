class CreateKits < ActiveRecord::Migration[5.2]
  def change
    create_table :kits do |t|
      t.string :remote_uid
      t.references :product, foreign_key: true
      t.references :inquiry, foreign_key: true
      t.timestamps
      t.userstamps
    end
  end
end
