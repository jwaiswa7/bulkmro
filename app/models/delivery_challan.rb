class DeliveryChallan < ApplicationRecord
  include Mixins::CanBeStamped

  attr_accessor :customer_inquiry_reference, :sales_order_number, :sales_order_date, :payment_terms

  belongs_to :inquiry
  belongs_to :sales_order, required: false
  belongs_to :purchase_order, required: false
  belongs_to :ar_invoice_request, required: false
  belongs_to :customer_bill_from, class_name: 'Address', required: false
  belongs_to :customer_ship_from, class_name: 'Address', required: false
  belongs_to :supplier_bill_from, class_name: 'Warehouse', required: false
  belongs_to :supplier_ship_from, class_name: 'Warehouse', required: false

  has_many :rows, class_name: 'DeliveryChallanRow', inverse_of: :delivery_challan, dependent: :destroy
  
  has_one_attached :customer_request_attachment

  accepts_nested_attributes_for :rows, reject_if: lambda { |attributes| (attributes['quantity'].blank? || attributes['quantity'].to_f < 0) && attributes['id'].blank? }, allow_destroy: true

  enum reason: {
    'Urgent Delivery of Goods and AR invoice not ready': 10,
    'Multiple delivery of goods against single AR Invoice': 20,
    'Urgent Delivery of Goods and SO not ready': 30,
    'Free Samples to be delivered': 40,
    'Partial Delivery of missed out goods on previous delivery': 50,
    'Other': 60,
    'Sample': 70
  }, _suffix: true

  enum goods_type: {
    "Transfer - Outward": 10,
    "Transfer - Inward": 20
  }

  enum purpose: {
    "Sample": 10,
    "Regular Flow": 20
  }

  def total_qty
    self.rows.sum(:quantity).to_i
  end
end