class DeliveryChallan < ApplicationRecord

  COMMENTS_CLASS = 'DeliveryChallanComment'
  attr_accessor :can_create_delivery_challan

  include Mixins::HasComments
  include Mixins::CanBeStamped
  include Mixins::HasConvertedCalculations

  attr_accessor :customer_inquiry_reference, :sales_order_number, :sales_order_date, :payment_terms
  update_index('delivery_challans') { self }
  belongs_to :inquiry
  has_one :inquiry_currency, through: :inquiry
  belongs_to :sales_order, required: false
  belongs_to :purchase_order, required: false
  belongs_to :ar_invoice_request, required: false
  belongs_to :inward_dispatch, required: false
  belongs_to :customer_bill_from, class_name: 'Address', required: false
  belongs_to :customer_ship_from, class_name: 'Address', required: false
  belongs_to :supplier_bill_from, class_name: 'Warehouse', required: false
  belongs_to :supplier_ship_from, class_name: 'Warehouse', required: false

  has_many :rows, class_name: 'DeliveryChallanRow', inverse_of: :delivery_challan, dependent: :destroy
  
  has_one_attached :customer_request_attachment
  scope :with_includes, -> { includes(:sales_order, :purchase_order, :inquiry, :ar_invoice_request, :created_by, :updated_by) }

  accepts_nested_attributes_for :rows, allow_destroy: true, reject_if: :all_blank

  enum reason: {
    'Urgent Delivery of Goods and AR Invoice not ready': 10,
    'Multiple Delivery of Goods against single AR Invoice': 20,
    'Urgent Delivery of Goods and SO not ready': 30,
    'Free Samples to be Delivered': 40,
    'Partial Delivery of missed out goods on Previous Delivery': 50,
    'Other': 60
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

  def filename(include_extension: false)
    [
        ['del', id].join('_'),
        ('pdf' if include_extension)
    ].compact.join('.')
  end
end
