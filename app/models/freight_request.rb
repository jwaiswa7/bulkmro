

class FreightRequest < ApplicationRecord
  COMMENTS_CLASS = 'FreightRequestComment'

  include Mixins::CanBeStamped
  include Mixins::HasComments

  belongs_to :inquiry
  belongs_to :company
  belongs_to :sales_order, required: false
  belongs_to :sales_quote

  belongs_to :supplier, -> (record) { where('id in (?)', record.inquiry.inquiry_product_suppliers.pluck(:supplier_id)) }, class_name: 'Company', foreign_key: :supplier_id, required: true
  belongs_to :pick_up_address, class_name: 'Address', foreign_key: :pick_up_address_id, required: true
  belongs_to :delivery_address, class_name: 'Address', foreign_key: :delivery_address_id, required: true

  has_one :freight_quote
  has_many_attached :attachments

  enum request_type: {
      'Domestic': 10,
      'International': 20
  }

  enum delivery_type: {
      'Regular': 10,
      'Dropship': 20
  }

  enum measurement: {
      'CM': 10,
      'IN': 20
  }

  enum status: {
      'Freight Quote Requested': 10,
      'Pending Info: IS & P': 20,
      'Awaiting Quote: 3PLs': 30,
      'Freight Quote Submitted': 40,
      'Cancelled': 50
  }

  enum loading: {
      'BM Scope': 10,
      'Supplier Scope': 20,
      'Customer Scope': 30
  }, _prefix: 'loading'

  enum unloading: {
      'BM Scope': 10,
      'Supplier Scope': 20,
      'Customer Scope': 30
  }, _prefix: 'unloading'

  [:length, :breadth, :width, :volumetric_weight].each do | field|
    validates_presence_of field
    validates_numericality_of field, greater_than: 0.00, message: 'should be numeric and greater than zero.'
  end

  after_initialize :set_defaults, if: :new_record?

  def set_defaults
    self.status ||= :'Freight Quote Requested'
    self.hazardous ||= :'No'
    self.measurement ||= :'CM'
    self.request_type ||= :'Domestic'
    self.delivery_type ||= :'Regular'
  end
end
