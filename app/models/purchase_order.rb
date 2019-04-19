class PurchaseOrder < ApplicationRecord
  COMMENTS_CLASS = 'PoComment'

  include Mixins::HasConvertedCalculations
  include Mixins::HasComments
  update_index('purchase_orders#purchase_order') {self}

  pg_search_scope :locate, against: [:id, :po_number], using: {tsearch: {prefix: true}}

  belongs_to :inquiry
  belongs_to :company, optional: true
  belongs_to :payment_option, required: false
  belongs_to :logistics_owner, -> (record) {where(role: 'logistics')}, class_name: 'Overseer', foreign_key: 'logistics_owner_id', optional: true
  has_one :inquiry_currency, through: :inquiry
  has_one :currency, through: :inquiry_currency
  has_one :conversion_rate, through: :inquiry_currency
  has_many :rows, class_name: 'PurchaseOrderRow', inverse_of: :purchase_order
  has_one_attached :document
  has_one :po_request
  has_one :payment_request
  has_one :invoice_request
  has_many :inward_dispatches
  has_many :email_messages
  has_many :products, through: :rows

  validates_with FileValidator, attachment: :document, file_size_in_megabytes: 2
  has_many_attached :attachments

  scope :with_includes, -> {includes(:inquiry, :po_request, :company)}
  scope :supplier_email_sent, -> { joins(:email_messages).where(email_messages: { email_type: 'Sending PO to Supplier' })}

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

  enum material_status: {
      'Material Readiness Follow-Up': 10,
      'Inward Dispatch': 20,
      'Inward Dispatch: Partial': 25,
      'Material Delivered': 30,
      'Material Partially Delivered': 35,
      'GRPO Pending': 40,
      'Pending AP Invoice': 45,
      'Pending AR Invoice': 50,
      'In stock': 55,
      'Completed AR Invoice Request': 60,
      'Cancelled AR Invoice': 65,
      'Cancelled': 70,
      'AP Invoice Request Rejected': 75,
      'GRPO Request Rejected': 80,
      'Inward Completed': 85,
      'Cancelled AP Invoice': 90,
      'Cancelled GRPO': 95
  }

  enum transport_mode: {
      'Road': 1,
      'Air': 2,
      'Sea': 3
  }

  scope :material_readiness_queue, -> {where.not(material_status: [:'Material Delivered'])}
  scope :material_pickup_queue, -> {where(material_status: :'Inward Dispatch')}
  scope :material_delivered_queue, -> {where(material_status: :'Material Delivered')}
  scope :not_cancelled, -> {where.not("metadata->>'PoStatus' = ?", PurchaseOrder.statuses[:Cancelled].to_s)}

  after_initialize :set_defaults, if: :new_record?

  def self.by_number(number)
    find_by_po_number(number)
  end

  def get_number
    self.po_number
  end

  def set_defaults
    self.material_status = 'Material Readiness Follow-Up'
  end

  def has_supplier?
    self.get_supplier(self.rows.first.metadata['PopProductId'].to_i).present?
  end

  def has_sent_email_to_supplier?
    self.email_messages.where(email_type: 'Sending PO to Supplier').present?
  end

  def email_sent_to_supplier_date
    self.email_messages.where(email_type: 'Sending PO to Supplier').last.created_at if has_sent_email_to_supplier?
  end

  def get_supplier(product_id = nil)
    if company.present?
      return company
    end

    if self.metadata['PoSupNum'].present?
      product_supplier = (Company.find_by_legacy_id(self.metadata['PoSupNum']) || Company.find_by_remote_uid(self.metadata['PoSupNum']))
      return product_supplier
    end

    if self.inquiry.final_sales_quote.present?
      product_supplier = self.inquiry.final_sales_quote.rows.select {|supplier_row| supplier_row.product.id == product_id || supplier_row.product.legacy_id == product_id}.first
      return product_supplier.supplier if product_supplier.present?
    end
  end

  def supplier
    return company if company.present?
    return po_request.supplier if po_request.present?
    return get_supplier(self.rows.first.metadata['PopProductId'].to_i) if self.rows.present?
  end

  def billing_address
    if self.metadata['PoSupBillFrom'].present?
      Address.find_by_remote_uid(self.metadata['PoSupBillFrom'])
    else
      supplier.billing_address
    end
  end

  def shipping_address
    if self.metadata['PoSupShipFrom'].present?
      Address.find_by_remote_uid(self.metadata['PoSupShipFrom'])
    else
      supplier.shipping_address
    end
  end

  def metadata_status
    PurchaseOrder.statuses.key(self.metadata['PoStatus'].to_i).to_s if self.metadata.present?
  end

  def to_s
    supplier_name = self.get_supplier(self.rows.first.metadata['PopProductId'].to_i) if self.rows.present?
    ['#' + po_number.to_s, supplier_name].join(' ') if po_number.present?
  end

  def calculated_total_with_tax
    (rows.map {|row| row.total_selling_price_with_tax || 0}.sum.round(2)) + self.metadata['LineTotal'].to_f + self.metadata['TaxSum'].to_f
  end

  def calculated_total_without_tax
    (rows.map {|row| row.total_selling_price || 0}.sum.round(2)) + self.metadata['LineTotal'].to_f
  end

  def warehouse
    if metadata['PoTargetWarehouse'].present?
      Warehouse.find_by(remote_uid: metadata['PoTargetWarehouse'].to_i)
    else
      inquiry.bill_from
    end
  end

  def get_packing(metadata)
    if metadata['PoShippingCost'].present?
      metadata['PoShippingCost'].to_f > 0 ? (metadata['PoShippingCost'].to_f + ' Amount Extra') : 'Included'
    else
      'Included'
    end
  end

  def valid_po_date?
    begin
      self.metadata['PoDate'].to_date
      true
    rescue ArgumentError
      false
    end
  end

  def po_date
    self.metadata['PoDate'].to_date if valid_po_date?
  end

  def update_material_status
    inward_dispatches = self.inward_dispatches.order(created_at: :desc)
    if inward_dispatches.any?
      invoice_request = inward_dispatches.first.invoice_request
      if invoice_request.present?
        self.update_attribute(:material_status, invoice_request.status)
      else
        partial = true
        if self.rows.sum(&:get_pickup_quantity) <= 0
          partial = false
        end
        if 'Material Pickup'.in? self.inward_dispatches.map(&:status)
          status = partial ? 'Inward Dispatch: Partial' : 'Inward Dispatch'
        elsif 'Material Delivered'.in? self.inward_dispatches.map(&:status)
          status = partial ? 'Material Partially Delivered' : 'Material Delivered'
        end
        self.update_attribute(:material_status, status)
      end
    else
      self.update_attribute(:material_status, 'Material Readiness Follow-Up')
    end
  end

  def po_request_present?
    self.po_request.present? ? (self.po_request.status == 'Supplier PO Sent' || self.po_request.status == 'Supplier PO: Created Not Sent') : false
  end

end
