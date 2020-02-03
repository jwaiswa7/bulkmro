class SupplierRfq < ApplicationRecord
  include Mixins::CanBeStamped

  has_many_attached :attachments
  belongs_to :inquiry
  has_many :inquiry_product_suppliers
  has_many :supplier_rfq_revisions, through: :inquiry_product_suppliers
  has_many :email_messages, dependent: :destroy

  accepts_nested_attributes_for :inquiry_product_suppliers

  enum status: {
      'Draft RFQ: Email Not Sent': 1,
      'Email Sent: Supplier Response Pending': 2,
      'Supplier Response Submitted': 3,
      'PO Issued': 4
  }

  def inquiry_product_suppliers_changed?
    inquiry_product_suppliers.any? { |ips| ips.saved_changes? }
  end

  def calculated_total
    self.inquiry_product_suppliers.map { |ips| ips.total_unit_cost_price_with_freight }.compact.sum
  end

  def calculated_total_with_tax
    self.inquiry_product_suppliers.map { |ips| ips.total_unit_cost_price_with_freight_with_tax }.compact.sum
  end
end
