class DropAndCreateIndex < ActiveRecord::Migration[5.2]
  def up
    add_index :company_contacts, [:company_id, :contact_id], unique: false
    add_index :company_contacts, :remote_uid, unique: false
    add_index :products, :remote_uid, unique: false
  end

  def down 
    remove_index :company_contacts, [:company_id, :contact_id]
    remove_index :company_contacts, :remote_uid
    remove_index :products, :remote_uid
  end
end
