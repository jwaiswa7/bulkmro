class DeliveryChallan < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :inquiry
  belongs_to :sales_order
  belongs_to :purchase_order
  belongs_to :ar_invoice_request
  
  has_many :rows, class_name: 'Dc Rows'
  
  has_one_attached :customer_request_attachment

  enum reason: { 
    'Urgent Delivery of Goods and AR invoice not ready': 10,
    'Multiple delivery of goods against single AR Invoice': 20,
    'Urgent Delivery of Goods and SO not ready': 30,
    'Free Samples to be delivered': 40,
    'Partial Delivery of missed out goods on previous delivery': 50
  }

  enum goods_type: {
    "Transfer - Outward": 10,
    "Transfer - Inward": 20
  }
end