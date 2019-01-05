class CompanyBank < ApplicationRecord

  belongs_to :company
  belongs_to :bank

  validates_presence_of :account_number

  validates_plausible_phone :beneficiary_mobile, allow_blank: true
end
