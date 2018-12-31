class CompanyBank < ApplicationRecord
  include Mixins::HasCountry

  belongs_to :company

  validates_presence_of :account_number, :address_line_1, :address_line_2, :name, :beneficiary_email
end
