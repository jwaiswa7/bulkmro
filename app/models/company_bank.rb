class CompanyBank < ApplicationRecord
  include Mixins::HasCountry

  belongs_to :company

  validates_presence_of :account_number, :address_line_1, :name, :beneficiary_email

  validates_plausible_phone :beneficiary_mobile, allow_blank: true
end
