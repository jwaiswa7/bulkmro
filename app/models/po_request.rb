class PoRequest < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :sales_order
  belongs_to :inquiry
  has_many :comments, class_name: 'PoRequestComment'
  has_many_attached :attachments
  accepts_nested_attributes_for :comments, reject_if: lambda {|attributes| attributes['message'].blank?}, allow_destroy: true

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
