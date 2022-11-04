class CreateWishLists < ActiveRecord::Migration[5.2]
  def change
    create_table :wish_lists do |t|
      t.references :contact, foreign_key: true
      t.references :company, foreign_key: true

      t.timestamps
    end
  end
end
