# frozen_string_literal: true

class PurchaseOrder < ApplicationRecord
  COMMENTS_CLASS = 'PoComment'

  include Mixins::HasConvertedCalculations
  include Mixins::HasComments
  update_index('purchase_orders#purchase_order') { self }

  pg_search_scope :locate, against: [:id, :po_number], using: { tsearch: { prefix: true } }

  belongs_to :inquiry
  belongs_to :payment_option, required: false
  has_one :inquiry_currency, through: :inquiry
  has_one :currency, through: :inquiry_currency
  has_one :conversion_rate, through: :inquiry_currency
  has_many :rows, class_name: 'PurchaseOrderRow', inverse_of: :purchase_order
  has_one_attached :document
  has_one :po_request
  has_one :payment_request
  has_one :invoice_request

  validates_with FileValidator, attachment: :document, file_size_in_megabytes: 2
  has_many_attached :attachments

  scope :with_includes, -> { includes(:inquiry) }

  def filename(include_extension: false)
    [
        ['po', po_number].join('_'),
        ('pdf' if include_extension)
    ].compact.join('.')
  end

  enum status: {
      'Supplier PO Created': 35,
      'PO Sent to Supplier': 36,
      'Supplier Order Confirmation Delayed': 38,
      'Material Readiness: Follow-Up': 39,
      'Material Readiness: Delayed': 41,
      'Shipment Booked: Under Process': 42,
      'Shipment Booking Delayed': 43,
      'Freight Forwarder: Requested Quote': 49,
      'Freight Forwarder: Requested Quote Delayed': 50,
      'Freight Forwarder: PO Sent': 51,
      'Freight Forwarder: PO Sent Delayed': 52,
      'HBL / HAWB Received': 53,
      'HBL / HAWB Delayed': 54,
      'HAZ Declaration': 55,
      'HAZ Declaration Delayed': 56,
      'Pre-Clearance Checklist Follow Up': 57,
      'Pre-Clearance Checklist Delayed': 58,
      'Pre-Clearance Checklist Approved': 59,
      'Bill of Entry Filing: Delayed': 60,
      'Duty Invoice Payment Request': 61,
      'Duty Invoice Payment Delayed': 62,
      'Supplier Pro Forma Invoice / Invoice Awaited': 63,
      'Supplier PI Pending Finance Approval': 64,
      'Supplier PI delayed': 67,
      'Payment to Supplier Delayed': 68,
      'payment_done_out_from_bm_warehouse': 69,
      'cancelled': 95,
      'Closed': 96
  }

  enum internal_status: {
      'Material Readiness Follow-Up': 10,
      'Material Pickup': 20,
      'Material Delivered': 30
  }

  scope :material_readiness_queue, -> { where(internal_status: :'Material Readiness Follow-Up') }
  scope :material_pickup_queue, -> { where(internal_status: :'Material Pickup') }
  scope :material_delivered_queue, -> { where(internal_status: :'Material Delivered') }
  scope :not_cancelled, -> { where.not("metadata->>'PoStatus' = ?", PurchaseOrder.statuses[:Cancelled].to_s) }

  def get_supplier(product_id)
    if self.metadata['PoSupNum'].present?
      product_supplier = (Company.find_by_legacy_id(self.metadata['PoSupNum']) || Company.find_by_remote_uid(self.metadata['PoSupNum']))
      return product_supplier if self.inquiry.suppliers.include?(product_supplier) || self.is_legacy?
    end

    if self.inquiry.final_sales_quote.present?
      product_supplier = self.inquiry.final_sales_quote.rows.select { | supplier_row |  supplier_row.product.id == product_id || supplier_row.product.legacy_id == product_id }.first
      return product_supplier.supplier if product_supplier.present?
    end
  end

  def metadata_status
    PurchaseOrder.statuses.key(self.metadata['PoStatus'].to_i).to_s if self.metadata.present?
  end

  def to_s
    supplier_name = self.get_supplier(self.rows.first.metadata['PopProductId'].to_i) if self.rows.present?
    ['#' + po_number.to_s, supplier_name].join(' ') if po_number.present?
  end

  def valid_po_date?
    begin
      self.metadata['PoDate'].to_date
      true
    rescue ArgumentError
      false
    end
  end
end
