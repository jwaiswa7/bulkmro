class AddContactEmailAndContactPhoneToPoRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :po_requests, :contact_email, :string
    add_column :po_requests, :contact_phone, :string
  end
end
