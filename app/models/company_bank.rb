class CompanyBank < ApplicationRecord
  include Mixins::HasCountry

  belongs_to :company

  validates_presence_of :account_number

  validates_plausible_phone :beneficiary_mobile, allow_blank: true
end
