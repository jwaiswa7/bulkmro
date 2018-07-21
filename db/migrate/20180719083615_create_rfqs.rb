class CreateRfqs < ActiveRecord::Migration[5.2]
  def change
    create_table :rfqs do |t|
      t.integer :supplier_id, index: true
      t.references :inquiry, foreign_key: true

      t.text :subject
      t.text :comments

      t.timestamps
      t.userstamps
    end
    add_foreign_key :rfqs, :companies, column: :supplier_id
  end
end
