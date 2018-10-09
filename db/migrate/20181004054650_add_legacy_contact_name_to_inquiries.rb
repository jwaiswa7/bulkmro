class AddLegacyContactNameToInquiries < ActiveRecord::Migration[5.2]
  def change
    add_column :inquiries, :legacy_contact_name, :string
  end
end
