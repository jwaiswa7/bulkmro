class SalesInvoice < ApplicationRecord
  belongs_to :sales_order

  has_many :receipts, class_name: 'SalesReceipt', inverse_of: :sales_invoice
  has_many :packages, class_name: 'SalesPackage', inverse_of: :sales_invoice
  has_many :rows, class_name: 'SalesInvoiceRow', inverse_of: :sales_invoice

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

  validates_presence_of :invoice_number
  validates_uniqueness_of :invoice_number

  def filename
    ['invoice', invoice_number].join('_')
  end
end
