class CreateRfqs < ActiveRecord::Migration[5.2]
  def change
    create_table :rfqs do |t|
      t.references :supplier, foreign_key: true
      t.references :inquiry, foreign_key: true

      t.timestamps
    end
  end
end
