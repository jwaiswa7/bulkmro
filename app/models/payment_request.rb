class PaymentRequest < ApplicationRecord
  COMMENTS_CLASS = 'PaymentRequestComment'

  include Mixins::CanBeStamped
  include Mixins::HasComments

  pg_search_scope :locate, :against => [:id, :utr_number], :associated_against => {:po_request => [:id, :purchase_order_id], :inquiry => [:inquiry_number]}, :using => {:tsearch => {:prefix => true}}

  belongs_to :inquiry
  belongs_to :purchase_order, required: false
  belongs_to :po_request
  has_many_attached :attachments

  enum status: {
      :'Created' => 10,
      :'Completed' => 20
  }

  scope :created, -> {where(:status => :'Created')}
  scope :completed, -> {where(:status => :'Completed')}

  validates_presence_of :inquiry

  after_initialize :set_defaults, :if => :new_record?

  def set_defaults
    self.status ||= :'Created'
  end

  def auto_update_status
    if self.utr_number.present?
      self.status = :'Completed'
    else
      self.status = :'Created'
    end
  end

  def completed?
    self.status == "Completed"
  end

  def requested?
    !self.completed?
  end
end
