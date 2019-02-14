class SalesInvoice < ApplicationRecord
  include Mixins::CanBeSynced
  update_index('sales_invoices#sales_invoice') { self }

  belongs_to :sales_order
  has_one :inquiry, through: :sales_order

  has_many :receipts,dependent: :destroy, class_name: 'SalesReceipt', inverse_of: :sales_invoice
  has_many :packages, class_name: 'SalesPackage', inverse_of: :sales_invoice
  has_many :rows, class_name: 'SalesInvoiceRow', inverse_of: :sales_invoice
  scope :not_cancelled_invoices, -> { where.not(:status => 'Cancelled')}
  has_many :sales_receipts
  has_one_attached :original_invoice
  has_one_attached :duplicate_invoice
  has_one_attached :triplicate_invoice
  has_one_attached :pod_attachment

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

  enum payment_status: {
      :'Fully Paid' => 10,
      :'Partially Paid' => 20,
      :'Unpaid' => 30,
  }

  scope :with_includes, -> { includes(:sales_order) }
  scope :not_cancelled, -> { where.not(status: 'Cancelled') }

  validates_with FileValidator, attachment: :original_invoice, file_size_in_megabytes: 2
  validates_with FileValidator, attachment: :duplicate_invoice, file_size_in_megabytes: 2
  validates_with FileValidator, attachment: :triplicate_invoice, file_size_in_megabytes: 2
  validates_presence_of :invoice_number
  validates_uniqueness_of :invoice_number

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

  def billing_address
    sales_order.billing_address || sales_order.inquiry.billing_address
  end

  def shipping_address
    sales_order.shipping_address || sales_order.inquiry.shipping_address
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

  def amount_received
    SalesReceipt.where(:sales_invoice_id => self.id).pluck(:payment_amount_received).compact.sum
  end

  def amount_received_against_invoice
    SalesReceipt.where(:sales_invoice_id => self.id,:payment_type => 'Against Invoice').pluck(:payment_amount_received).compact.sum
  end

  def amount_received_on_account
    SalesReceipt.where(:sales_invoice_id => self.id,:payment_type => 'On Account').pluck(:payment_amount_received).compact.sum
  end

  def get_due_date
    due_in_days = 30
    if self.inquiry.present? && self.inquiry.payment_option.present?
      due_in_days = self.inquiry.payment_option.get_days
    end
    self.created_at + due_in_days.days
  end

  def get_due_days
    sales_receipt_dates = self.sales_receipts.pluck(:payment_received_date).compact
    due_date = self.due_date
    max_date = sales_receipt_dates.max
    days = "-"
    if due_date.present?
      if max_date.nil? || due_date < max_date
        days = "#{((Time.now - self.get_due_date) / 86400).to_i} days"
      end
    end
    days
  end

end
