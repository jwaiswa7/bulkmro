class MaterialReadinessFollowup < ApplicationRecord
  COMMENTS_CLASS = 'MrfComment'

  include Mixins::HasComments

  belongs_to :purchase_order
  belongs_to :logistics_owner, -> (record) {where(:role => 'logistics')}, :class_name => 'Overseer', foreign_key: 'logistics_owner_id', optional: true
  has_many :rows, -> {joins(:purchase_order_row)}, class_name: 'MrfRow', inverse_of: :material_readiness_followup, dependent: :destroy
  has_many_attached :attachments

  accepts_nested_attributes_for :rows, reject_if: lambda {|attributes| attributes['id'].blank?}, allow_destroy: true

  enum type_of_doc: {
      tax_invoice: 10,
      proforma_invoice: 20
  }

  enum status: {
      :'Material Pickup' => 10,
      :'Material Delivered' => 20
  }, _prefix: true


  after_initialize :set_defaults, :if => :new_record?

  validate :material_delivered_prerequisite?

  def material_delivered_prerequisite?

    if( self.status == 'Material Delivered' && self.attachments.blank?)
      self.errors.add(:attachments,' need to be present to Confirm Delivery')

    end

  end

  def set_defaults
    self.expected_dispatch_date = DateTime.now
    self.expected_delivery_date = DateTime.now
    self.actual_delivery_date = DateTime.now
  end

end
