class Bank < ApplicationRecord
  include Mixins::HasCountry

  has_many :company_banks
  has_many :companies, through: :company_banks

  validates_presence_of :name, :code, :swift_number
end
