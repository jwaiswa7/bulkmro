class SalesInvoice < ApplicationRecord
  include Mixins::CanBeSynced
  include DisplayHelper
  update_index('sales_invoices#sales_invoice') { self }

  pg_search_scope :locate, against: [:id, :invoice_number], associated_against: { company: [:name], account: [:name], inside_sales_owner: [:first_name, :last_name], outside_sales_owner: [:first_name, :last_name] }, using: { tsearch: { prefix: true } }

  belongs_to :sales_order
  belongs_to :billing_address, class_name: 'Address', required: false
  belongs_to :shipping_address, class_name: 'Address', required: false

  has_one :inquiry, through: :sales_order

  has_many :receipts, class_name: 'SalesReceipt', inverse_of: :sales_invoice
  has_many :packages, class_name: 'SalesPackage', inverse_of: :sales_invoice
  has_many :rows, class_name: 'SalesInvoiceRow', inverse_of: :sales_invoice
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

  scope :with_includes, -> { includes(:sales_order) }
  scope :not_cancelled, -> { where.not(status: 'Cancelled') }

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
end
