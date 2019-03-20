class AddPhoneNumberFieldToCompanyCreationRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :company_creation_requests, :phone_number, :integer
    add_column :company_creation_requests, :create_new_contact, :boolean
  end
end
