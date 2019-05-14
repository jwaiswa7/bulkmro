class AddPhoneNumberFieldToCompanyCreationRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :company_creation_requests, :telephone, :string
    add_column :company_creation_requests, :mobile_number, :string
    add_column :company_creation_requests, :create_new_contact, :boolean
    add_column :company_creation_requests, :contact_creation_request_id, :integer
  end
end
