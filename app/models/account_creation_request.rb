class AccountCreationRequest < ApplicationRecord
  belongs_to :company_creation_request
  validates_presence_of :name
  validates_presence_of :account_type

  enum :account_type => {
      :is_supplier => 10,
      :is_customer => 20
  	}

end
