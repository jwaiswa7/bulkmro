

class Bank < ApplicationRecord
  include Mixins::HasCountry
  include Mixins::CanBeSynced

  update_index('banks#bank') { self }
  pg_search_scope :locate, against: [:name, :code, :swift_number], using: { tsearch: { prefix: true } }

  has_many :company_banks
  has_many :companies, through: :company_banks

  scope :with_includes, -> { includes(:company_banks, :companies) }

  validates_presence_of :name, :code
  validates_uniqueness_of :name, :code, :swift_number, allow_blank: true
end
