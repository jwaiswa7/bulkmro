class CreateAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :addresses do |t|
      t.references :company, foreign_key: true

      t.string :name
      t.string :street1
      t.string :street2

      t.timestamps
      t.userstamps
    end
  end
end
