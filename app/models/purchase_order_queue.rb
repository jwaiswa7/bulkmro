class PurchaseOrderQueue < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :sales_order
  belongs_to :inquiry

  has_many :purchase_order_comments
  has_many_attached :attachments

  accepts_nested_attributes_for :purchase_order_comments, reject_if: lambda {|attributes| attributes['message'].blank?}, allow_destroy: true

  enum status: {
      :'Requested' => 10,
      :'PO Created' => 20,
      :'Cancelled' => 30
  }

  after_initialize :set_defaults, :if => :new_record?


  def set_defaults
    self.status = 10
  end

end
