class AddShippingContactToInquiries < ActiveRecord::Migration[5.2]
  def change
    add_column :inquiries, :shipping_contact_id, :integer, index: true

    add_foreign_key :inquiries, :contacts, column: :shipping_contact_id
  end
end
