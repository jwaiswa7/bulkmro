class AccountCreationRequest < ApplicationRecord
  belongs_to :company_creation_request
  validates_presence_of :name
end
