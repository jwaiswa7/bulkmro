class FixColumnNameForContactCreationRequest < ActiveRecord::Migration[5.2]
  def change
    rename_column :contact_creation_requests, :phone_number, :telephone
    rename_column :contact_creation_requests, :mobile_number, :mobile
  end
end
