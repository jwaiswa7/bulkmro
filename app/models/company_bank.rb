class CompanyBank < ApplicationRecord
  include Mixins::CanBeSynced

  belongs_to :company
  belongs_to :bank

  validates_presence_of :account_number
  validates :account_number, uniqueness: true

  validates_plausible_phone :beneficiary_mobile, allow_blank: true

end
