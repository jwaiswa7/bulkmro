class Bank < ApplicationRecord
  include Mixins::HasCountry
  include Mixins::CanBeSynced

  has_many :company_banks
  has_many :companies, through: :company_banks

  validates_presence_of :name, :code
end
