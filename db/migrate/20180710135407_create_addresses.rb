class CreateAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :addresses do |t|
      t.references :company, foreign_key: true

      t.timestamps
    end
  end
end
