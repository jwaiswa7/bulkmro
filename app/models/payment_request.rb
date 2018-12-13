class PaymentRequest < ApplicationRecord
  COMMENTS_CLASS = 'PaymentRequestComment'

  include Mixins::CanBeStamped
  include Mixins::HasComments

  pg_search_scope :locate, :against => [:id, :utr_number], :associated_against => {:po_request => [:id, :purchase_order_id], :inquiry => [:inquiry_number]}, :using => {:tsearch => {:prefix => true}}

  belongs_to :inquiry
  belongs_to :purchase_order
  belongs_to :po_request
  has_many_attached :attachments
  has_one :payment_option, :through => :purchase_order

  enum status: {
      :'Pending' => 10,
      :'Completed' => 20
  }

  scope :Pending, -> {where(:status => :'Pending')}
  scope :completed, -> {where(:status => :'Completed')}

  validates_presence_of :inquiry

  after_initialize :set_defaults, :if => :new_record?

  def set_defaults
    self.status ||= :'Pending'
  end

  def auto_update_status
    if self.utr_number.present?
      self.status = :'Completed'
    else
      self.status = :'Pending'
    end
  end
end
