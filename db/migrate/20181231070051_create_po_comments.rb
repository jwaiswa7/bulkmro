class CreatePoComments < ActiveRecord::Migration[5.2]
  def change
    create_table :po_comments do |t|
      t.references :purchase_order, foreign_key: true
      t.text :message

      t.userstamps
      t.timestamps
    end
  end
end
