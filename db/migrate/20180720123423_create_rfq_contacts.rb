class CreateRfqContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :rfq_contacts do |t|
      t.references :rfq, foreign_key: true
      t.references :contact, foreign_key: true

      t.timestamps
      t.userstamps
    end

    add_index :rfq_contacts, [:rfq_id, :contact_id], unique: true
  end
end
