class AddPhoneNumberFieldToCompanyCreationRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :company_creation_requests, :telephone, :integer
    add_column :company_creation_requests, :mobile_number, :integer
    add_column :company_creation_requests, :create_new_contact, :boolean
    add_column :company_creation_requests, :contact_creation_request_id, :integer
  end
end
