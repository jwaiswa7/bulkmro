# frozen_string_literal: true

class CompanyBank < ApplicationRecord
  include Mixins::CanBeSynced

  update_index('company_banks#company_bank') { self }
  pg_search_scope :locate, against: [:account_number, :account_name, :branch], associated_against: { bank: [:name] }, using: { tsearch: { prefix: true } }

  belongs_to :company
  belongs_to :bank

  scope :with_includes, -> { includes(:bank, :company) }

  validates_presence_of :account_number

  validates_plausible_phone :beneficiary_mobile, allow_blank: true
end
