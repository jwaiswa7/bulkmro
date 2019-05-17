class SalesInvoice < ApplicationRecord
  include Mixins::CanBeSynced
  include DisplayHelper
  include Mixins::HasConvertedCalculations
  update_index('sales_invoices#sales_invoice') { self }
  update_index('customer_order_status_report#sales_order') { sales_order }
  update_index('logistics_scorecards#sales_invoice') {self}

  pg_search_scope :locate, against: [:id, :invoice_number], associated_against: { company: [:name], account: [:name], inside_sales_owner: [:first_name, :last_name], outside_sales_owner: [:first_name, :last_name] }, using: { tsearch: { prefix: true } }

  belongs_to :sales_order
  belongs_to :billing_address, class_name: 'Address', required: false
  belongs_to :shipping_address, class_name: 'Address', required: false

  has_one :inquiry, through: :sales_order

  has_many :receipts, class_name: 'SalesReceipt', inverse_of: :sales_invoice
  has_many :packages, class_name: 'SalesPackage', inverse_of: :sales_invoice
  has_many :rows, class_name: 'SalesInvoiceRow', inverse_of: :sales_invoice
  has_many :email_messages
  has_many :sales_receipts
  has_many :sales_receipt_rows
  has_many :email_messages
  has_many :pod_rows, dependent: :destroy
  accepts_nested_attributes_for :pod_rows, reject_if: lambda { |attributes|
    if attributes[:id].present?
      PodRow.find(attributes[:id]).attachments.count < 1
    else
      attributes[:attachments].blank?
    end
  }, allow_destroy: true



  has_one_attached :original_invoice
  has_one_attached :duplicate_invoice
  has_one_attached :triplicate_invoice
  has_one_attached :pod_attachment

  scope :not_cancelled_invoices, -> { where.not(status: 'Cancelled') }
  scope :not_paid, -> { where.not(payment_status: 'Fully Paid') }

  enum status: {
      'Open': 1,
      'Paid': 2,
      'Cancelled': 3,
      'Partial: Shipped': 201,
      'Shipped': 202,
      'Material Delivery Delayed': 203,
      'Delivered: GRN Pending': 204,
      'Delivered: GRN Delayed': 205,
      'Material Ready For Dispatch': 206,
      'Material Rejected': 207
  }

  enum delay_reason: {
      'Logistics Delivery Delay': 10,
      'SO Creation Delay': 20,
      'Supplier PO Creation Delay': 30,
      'Supplier Delay': 40
  }

  enum sla_bucket: {
      'Not Delivered': 0,
      'On or before Time': 1,
      'Delayed': 2
  }

  enum delay_bucket: {
      'Not Delivered': 0,
      'No delay': 1,
      'Delay by 2 days': 2,
      'Delay by 2-7 days': 3,
      'Delay by 7-14 days': 4,
      'Delay by 14-28 days': 5,
      'Delay by >28 days': 6
  }, _prefix: true

  scope :with_includes, -> { includes(:sales_order) }
  scope :not_cancelled, -> { where.not(status: 'Cancelled') }
  scope :cancelled, -> { where(status: 'Cancelled') }

  validates_with FileValidator, attachment: :original_invoice, file_size_in_megabytes: 2
  validates_with FileValidator, attachment: :duplicate_invoice, file_size_in_megabytes: 2
  validates_with FileValidator, attachment: :triplicate_invoice, file_size_in_megabytes: 2
  validates_presence_of :invoice_number
  validates_uniqueness_of :invoice_number

  def self.by_number(number)
    find_by_invoice_number(number)
  end

  def get_number
    self.invoice_number
  end

  def filename(include_extension: false)
    [
        ['invoice', invoice_number].join('_'),
        ('pdf' if include_extension)
    ].compact.join('.')
  end

  def zipped_filename(include_extension: false)
    [
        ['invoices', invoice_number].join('_'),
        ('zip' if include_extension)
    ].compact.join('.')
  end

  def serialized_billing_address
    billing_address || sales_order.inquiry.billing_address
  end

  def serialized_shipping_address
    shipping_address || sales_order.inquiry.shipping_address
  end

  def self.syncable_identifiers
    [:invoice_number]
  end

  def calculated_total
    rows.map { |row| (row.metadata['base_row_total'].to_f * row.sales_invoice.metadata['base_to_order_rate'].to_f) }.sum.round(2)
  end

  def calculated_total_tax
    rows.map { |row| (row.metadata['base_tax_amount'].to_f * row.sales_invoice.metadata['base_to_order_rate'].to_f) }.sum.round(2)
  end

  def calculated_total_with_tax
    (calculated_total.to_f + calculated_total_tax.to_f).round(2)
  end

  def has_attachment?
    self.pod_rows.present? && self.pod_rows.order(:delivery_date).last.attachments.attached? && self.delivery_completed
  end

  def pod_status
    if self.pod_rows.present? && self.pod_rows.order(:delivery_date).last.attachments.attached?
      if self.delivery_completed
        'complete'
      else
        'partial'
      end
    else
      'incomplete'
    end
  end

  def delivery_date
    if self.pod_rows.present?
      self.pod_rows.order(:delivery_date).last.delivery_date
    end
  end

  def amount_received
    # SalesReceipt.where(:sales_invoice_id => self.id).pluck(:payment_amount_received).compact.sum
    SalesReceiptRow.where('sales_invoice_id': self.id).sum(:amount_received)
  end

  def amount_received_against_invoice
    # SalesReceipt.where(:sales_invoice_id => self.id,:payment_type => 'Against Invoice').pluck(:payment_amount_received).compact.sum
    SalesReceiptRow.where('sales_invoice_id': self.id).sum(:amount_received)
  end

  # Not needed, there won't be any on account payment for invoice

  # def amount_received_on_account
  #   SalesReceipt.where(:sales_invoice_id => self.id,:payment_type => 'On Account').pluck(:payment_amount_received).compact.sum
  # end

  def get_due_date
    due_in_days = 30
    if self.inquiry.present? && self.inquiry.payment_option.present?
      due_in_days = self.inquiry.payment_option.get_days
    end
    self.created_at + due_in_days.days
  end

  def get_due_days
    days = '-'
    amount_due = self.amount_due
    if due_date.present? && due_date < Date.today && self.amount_due > 0.0
      if due_date.present?
        if self.amount_received < amount_due
          days = "#{((Time.now - self.get_due_date) / 86400).to_i} days"
        end
      end
    end
    days
  end

  def amount_due
    self.calculated_total_with_tax - self.amount_received
  end

  def overdue_amount
    self.due_date < DateTime.now ? self.amount_due : 0.0
  end

  def nodue_amount
    self.due_date > DateTime.now ? self.amount_due : 0.0
  end

  def overdue_amt_in_days(start_day, end_day = nil)
    due_date = self.due_date
    todays_date = DateTime.now
    due_amt = 0.0
    if due_date < todays_date
      due_days = ((Time.now - due_date) / 86400).to_i
      if end_day.present?
        due_amt = (start_day..end_day).include?(due_days) ? self.amount_due.to_s : 0.0
      else
        due_amt = (due_days > start_day) ? self.amount_due : 0.0
      end
    end
    due_amt
  end

  def nodue_amt_in_days(start_day, end_day = nil)
    due_date = self.due_date
    todays_date = DateTime.now
    due_amt = 0.0
    if due_date > todays_date
      due_days = ((due_date - Time.now) / 86400).to_i
      p due_days
      if end_day.present?
        due_amt = (start_day..end_day).include?(due_days) ? self.amount_due.to_s : 0.0
      else
        due_amt = (due_days > start_day) ? self.amount_due : 0.0
      end
    end
    due_amt
  end

  def calculated_freight_cost_total
    self.rows.sum(&:freight_cost_subtotal).round(2)
  end

  def calculate_committed_delivery_tat
    if self.inquiry.customer_committed_date.present? && self.inquiry.customer_po_received_date.present?
      Chewy.strategy(:atomic) do
        self.update_attribute(:committed_delivery_tat, (self.inquiry.customer_committed_date - self.inquiry.customer_po_received_date).to_i)
      end
    end
  end

  def calculate_actual_delivery_tat
    if self.delivery_date.present? && self.inquiry.customer_order_date.present?
      Chewy.strategy(:atomic) do
        self.update_attribute(:actual_delivery_tat, (self.delivery_date - self.inquiry.customer_order_date).to_i)
      end
    end
  end

  def calculate_delay
    if self.committed_delivery_tat.present? && self.actual_delivery_tat.present?
      Chewy.strategy(:atomic) do
        self.update_attribute(:delay, (self.actual_delivery_tat - self.committed_delivery_tat).to_i)
      end
    end
  end

  def calculate_sla_bucket
    if ['', nil].include?(self.delay)
      'Not Delivered'
    elsif self.delay <= 0
      'On or before Time'
    else
      'Delayed'
    end
  end

  def calculate_delay_bucket
    if ['', nil].include?(self.delay)
      0
    elsif self.delay <= 0
      1
    elsif self.delay <= 2
      2
    elsif self.delay <= 7
      3
    elsif self.delay <= 14
      4
    elsif self.delay <= 28
      5
    else
      6
    end
  end
end
