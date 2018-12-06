class PoRequest < ApplicationRecord
  COMMENTS_CLASS = 'PoRequestComment'

  include Mixins::CanBeStamped
  include Mixins::HasComments

  pg_search_scope :locate, :against => [:id], :associated_against => {:sales_order => [:id, :order_number], :inquiry => [:inquiry_number]}, :using => {:tsearch => {:prefix => true}}

  belongs_to :sales_order
  belongs_to :inquiry
  has_many :po_request_products
  has_many_attached :attachments

  enum status: {
      :'Requested' => 10,
      :'PO Created' => 20,
      :'Cancelled' => 30
  }

  scope :pending, -> { where(:status => :'Requested') }
  scope :handled, -> { where.not(:status => :'Requested') }

  accepts_nested_attributes_for :po_request_products

  after_initialize :set_defaults, :if => :new_record?

  def set_defaults
    self.status = :'Requested'
  end
end
