class Account < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::HasUniqueName
  include Mixins::CanBeSynced

  pg_search_scope :locate, against: [:name], associated_against: {}, using: { tsearch: { prefix: true } }

  # validates_presence_of :alias
  # validates_uniqueness_of :alias
  # validates_length_of :alias, :maximum => 20
  has_many :email_messages, dependent: :destroy
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
  has_many :sales_receipts, :class_name => 'SalesReceipt'
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

  def total_amount_received
    self.amount_received_against_invoice + self.amount_received_on_account
  end

  def amount_received_on_account
    self.sales_receipts.where(:payment_type => :'On Account').sum(:payment_amount_received)
  end

  def amount_received_against_invoice
    amount = 0.0
    self.invoices.where('sales_invoices.mis_date >= ?', '01-04-2018').each do |sales_invoice|
      amount = amount + sales_invoice.sales_receipts.where(:payment_type => :'Against Invoice').sum(:payment_amount_received)
    end
    amount
  end

  def total_amount_due
    self.invoices.where('sales_invoices.mis_date >= ?', '01-04-2018').sum(:calculated_total_with_tax)
  end

  def amount_overdue_outstanding
    # invoice date is crossed and payment is not received yet
    amount = 0.0
    self.invoices.where('sales_invoices.mis_date >= ?', '01-04-2018').each do |sales_invoice|
      outstanding_amount = sales_invoice.calculated_total_with_tax
      sales_invoice.sales_receipts.each do |sales_receipt|
        if (sales_receipt.payment_received_date < sales_invoice.due_date) || (sales_receipt.payment_received_date < Date.today)
          outstanding_amount -= sales_receipt.payment_amount_received
        end
      end
      amount += outstanding_amount
    end
    amount
  end

  def total_amount_outstanding
    amount = self.total_amount_due - self.total_amount_received
    (amount <  0.0) ? 0.0 : amount
  end
end
