class FreightRequest < ApplicationRecord
  COMMENTS_CLASS = 'FreightRequestComment'

  include Mixins::CanBeStamped
  include Mixins::HasComments

  belongs_to :inquiry
  belongs_to :company
  belongs_to :sales_order, required: false
  belongs_to :sales_quote

  belongs_to :supplier, -> (record) {where('id in (?)', record.inquiry.inquiry_product_suppliers.pluck(:supplier_id))}, class_name: 'Company', foreign_key: :supplier_id, required: true
  belongs_to :pick_up_address, class_name: 'Address', foreign_key: :pick_up_address_id, required: true
  belongs_to :delivery_address, class_name: 'Address', foreign_key: :delivery_address_id, required: true

  has_one :freight_quote
  has_many_attached :attachments

  enum request_type: {
      :'Domestic' => 10,
      :'International' => 20
  }

  enum delivery_type: {
      :'Regular' => 10,
      :'Dropship' => 20
  }

  enum measurement: {
      :'CM' => 10,
      :'IN' => 20
  }

  enum status: {
      :'Requested' => 10,
      :'Completed' => 20,
      :'Cancelled' => 20,
  }

  after_initialize :set_defaults, :if => :new_record?

  def set_defaults
    self.status ||= :'Requested'
    self.hazardous ||= :'No'
    self.measurement ||= :'CM'
    self.request_type ||= :'Domestic'
    self.delivery_type ||= :'Regular'
  end

end
