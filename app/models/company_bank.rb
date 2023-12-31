class CompanyBank < ApplicationRecord
  include Mixins::CanBeSynced

  update_index('company_banks') { self }
  pg_search_scope :locate, against: [:account_number, :account_name, :branch], associated_against: { bank: [:name] }, using: { tsearch: { prefix: true } }

  belongs_to :company
  belongs_to :bank
  belongs_to :ifsc_code
  has_many :payment_requests
  has_many_attached :attachments

  scope :with_includes, -> { includes(:bank, :company) }

  validates_presence_of :account_number
  validates_confirmation_of :account_number, if: :new_record?
  validates_confirmation_of :account_number, if: :account_number_changed?
  validates_presence_of :account_number_confirmation, if: :account_number_changed?
  phony_normalize :beneficiary_mobile, default_country_code: 'IN'

  def to_s
    [self.bank, branch, self.bank.ifsc_code, account_number, account_name].reject(&:blank?).join(', ')
  end
end
