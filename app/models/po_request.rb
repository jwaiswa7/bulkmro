class PoRequest < ApplicationRecord
  COMMENTS_CLASS = 'PoRequestComment'

  include Mixins::CanBeStamped
  include Mixins::HasComments

  pg_search_scope :locate, :against => [:id, :po_number], :associated_against => {:inquiry => [:inquiry_number]}, :using => {:tsearch => {:prefix => true}}

  belongs_to :sales_order
  belongs_to :inquiry
  has_many_attached :attachments

  enum status: {
      :'Requested' => 10,
      :'PO Created' => 20,
      :'Cancelled' => 30
  }

  scope :pending, -> { where(:status => :'Requested') }
  scope :handled, -> { where.not(:status => :'Requested') }

  after_initialize :set_defaults, :if => :new_record?

  def set_defaults
    self.status = :'Requested'
  end
end
