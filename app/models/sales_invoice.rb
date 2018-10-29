class SalesInvoice < ApplicationRecord
  include Mixins::CanBeSynced
  update_index('sales_invoices#sales_invoice') {self}

  belongs_to :sales_order
  has_one :inquiry, :through => :sales_order

  has_many :receipts, class_name: 'SalesReceipt', inverse_of: :sales_invoice
  has_many :packages, class_name: 'SalesPackage', inverse_of: :sales_invoice
  has_many :rows, class_name: 'SalesInvoiceRow', inverse_of: :sales_invoice

  has_one_attached :original_invoice
  has_one_attached :duplicate_invoice
  has_one_attached :triplicate_invoice

  enum status: {
      :'Open' => 1,
      :'Paid' => 2,
      :'Unpaid' => 3,
      :'Partial: Shipped' => 201,
      :'Shipped' => 202,
      :'Material Delivery Delayed' => 203,
      :'Delivered: GRN Pending' => 204,
      :'Delivered: GRN Delayed' => 205,
      :'Material Ready For Dispatch' => 206,
      :'Material Rejected' => 207
  }

  scope :with_includes, -> {includes(:sales_order)}

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

  def self.syncable_identifiers
    [:invoice_number]
  end
end
