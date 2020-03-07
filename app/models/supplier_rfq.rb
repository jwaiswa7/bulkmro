class SupplierRfq < ApplicationRecord
  include Mixins::CanBeStamped

  has_many_attached :attachments
  belongs_to :inquiry
  has_many :inquiry_product_suppliers
  has_many :supplier_rfq_revisions, through: :inquiry_product_suppliers
  has_many :email_messages, dependent: :destroy

  update_index('supplier_rfqs#supplier_rfq') {self}

  accepts_nested_attributes_for :inquiry_product_suppliers
  scope :with_includes, -> { includes(:created_by, :updated_by, :inquiry) }

  enum status: {
      'Draft RFQ: Email Not Sent': 1,
      'RFQ Email Received: Pending Reply': 2,
      'PQ Sent': 3,
      'PO Issued': 4
  }

  after_initialize :set_defaults, if: :new_record?

  def set_defaults
    self.status = 'Draft RFQ: Email Not Sent'
  end

  def inquiry_product_suppliers_changed?
    inquiry_product_suppliers.any? { |ips| ips.saved_changes? }
  end

  def calculated_total
    self.inquiry_product_suppliers.map { |ips| ips.total_unit_cost_price_with_freight }.compact.sum
  end

  def calculated_total_with_tax
    self.inquiry_product_suppliers.map { |ips| ips.total_unit_cost_price_with_freight_with_tax }.compact.sum
  end

  def self.readable_action(action_name)
    if  action_name == 'edit_supplier_rfqs'
      'Edit Supplier RFQs'
    elsif action_name == 'rfq_review'
      'RFQ Review'
    end
  end
end
