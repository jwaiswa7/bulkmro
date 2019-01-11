class CompanyCreationRequest < ApplicationRecord
  belongs_to :activity
  belongs_to :account
  has_one :company
  has_one :account_creation_request
  validates_presence_of :name
  accepts_nested_attributes_for :account_creation_request, reject_if: lambda { |attributes| attributes['name'].blank? && attributes['account_type'].blank? }, allow_destroy: true
end