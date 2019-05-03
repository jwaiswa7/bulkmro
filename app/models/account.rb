class Account < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::HasUniqueName
  include Mixins::CanBeSynced
  include Mixins::HasPaymentCollections

  pg_search_scope :locate, against: [:name], associated_against: {}, using: { tsearch: { prefix: true } }

  # validates_presence_of :alias
  # validates_uniqueness_of :alias
  # validates_length_of :alias, :maximum => 20

  has_many :companies
  has_many :company_creation_request
  has_many :contacts
  has_many :inquiries, through: :companies
  has_many :inquiry_products, through: :inquiries
  has_many :products, through: :inquiry_products
  has_many :sales_orders, through: :inquiries
  has_many :invoices, through: :inquiries
  has_many :sales_quotes, through: :inquiries, source: 'final_sales_quote'
  has_many :addresses, through: :companies
  has_many :sales_receipts
  has_many :payment_collections
  enum account_type: {
      is_supplier: 10,
      is_customer: 20,
  }

  validates_presence_of :account_type

  after_initialize :set_defaults, if: :new_record?
  def set_defaults
    self.account_type ||= :is_customer
  end

  def syncable_identifiers
    [:remote_uid]
  end

  def self.legacy
    find_by_name('Legacy Account')
  end

  def self.trade
    find_by_name('Trade')
  end

  def self.non_trade
    find_by_name('Non-Trade')
  end
end
