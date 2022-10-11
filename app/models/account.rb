class Account < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::HasUniqueName
  include Mixins::CanBeSynced
  include Mixins::HasPaymentCollections

  pg_search_scope :locate, against: [:name], associated_against: {}, using: {tsearch: {prefix: true}}

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
  has_many :email_messages
  has_many :customer_rfqs, dependent: :destroy
  has_one_attached :logo
  


  has_many :annual_targets
  has_many :account_targets

  enum account_type: {
      is_supplier: 10,
      is_customer: 20,
  }

  validates_presence_of :account_type
  validates_with ImageFileValidator, attachment: :logo

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

  def get_monthly_target(date_range)
    if date_range.present? && date_range['date_range'].present?
      from = date_range['date_range'].split('~').first.to_date.strftime('%Y-%m-01')
      to = date_range['date_range'].split('~').last.to_date.strftime('%Y-%m-01')
      target_periods = TargetPeriod.where(period_month: from..to).pluck(:id)
    else
      from = "#{Date.today.year}-04-01"
      to = Date.today.strftime('%Y-%m-%d')
      target_periods = TargetPeriod.where(period_month: from..to).pluck(:id)
    end
    if self.account_targets.present?
      monthly_targets = self.account_targets.where(target_period_id: target_periods)
      monthly_targets.last.target_value.to_i if monthly_targets.present?
    else
      0
    end
  end
end
