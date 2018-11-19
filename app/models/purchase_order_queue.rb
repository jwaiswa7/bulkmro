class PurchaseOrderQueue < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :sales_order
  belongs_to :inquiry

  enum status: {
      :'Requested' => 10,
      :'PO Created' => 20
  }

  after_initialize :set_defaults, :if => :new_record?

  def set_defaults
    self.status = 10
  end
end
