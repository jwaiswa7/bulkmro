class PurchaseOrder < ApplicationRecord
  include Mixins::HasConvertedCalculations
  update_index('purchase_orders#purchase_order') {self}

  belongs_to :inquiry
  has_one :inquiry_currency, :through => :inquiry
  has_one :currency, :through => :inquiry_currency
  has_one :conversion_rate, :through => :inquiry_currency
  has_many :rows, class_name: 'PurchaseOrderRow', inverse_of: :purchase_order
  has_one_attached :document

  validates_with FileValidator, attachment: :document, file_size_in_megabytes: 2

  scope :with_includes, -> {includes(:inquiry)}

  def filename(include_extension: false)
    [
        ['po', po_number].join('_'),
        ('pdf' if include_extension)
    ].compact.join('.')
  end

  enum status: {
      :'Supplier PO Created' => 35,
      :'PO Sent to Supplier' => 36,
      :'Supplier Order Confirmation Delayed' => 38,
      :'Material Readiness: Follow-Up' => 39,
      :'Material Readiness: Delayed' => 41,
      :'Shipment Booked: Under Process' => 42,
      :'Shipment Booking Delayed' => 43,
      :'Freight Forwarder: Requested Quote' => 49,
      :'Freight Forwarder: Requested Quote Delayed' => 50,
      :'Freight Forwarder: PO Sent' => 51,
      :'Freight Forwarder: PO Sent Delayed' => 52,
      :'HBL / HAWB Received' => 53,
      :'HBL / HAWB Delayed' => 54,
      :'HAZ Declaration' => 55,
      :'HAZ Declaration Delayed' => 56,
      :'Pre-Clearance Checklist Follow Up' => 57,
      :'Pre-Clearance Checklist Delayed' => 58,
      :'Pre-Clearance Checklist Approved' => 59,
      :'Bill of Entry Filing: Delayed' => 60,
      :'Duty Invoice Payment Request' => 61,
      :'Duty Invoice Payment Delayed' => 62,
      :'Supplier Pro Forma Invoice / Invoice Awaited' => 63,
      :'Supplier PI Pending Finance Approval' => 64,
      :'Supplier PI delayed' => 67,
      :'Payment to Supplier Delayed' => 68,
      :'Cancelled' => 95,
      :'Closed' => 96
  }

  def get_supplier(product_id)

    if self.metadata['PoSupNum'].present?
      product_supplier = Company.find_by_remote_uid(self.metadata['PoSupNum'])
      return product_supplier if self.inquiry.suppliers.include? product_supplier
    end

    product_supplier = self.inquiry.final_sales_quote.rows.select { | supplier_row |  supplier_row.product.id == product_id || supplier_row.product.legacy_id  == product_id}.first
    product_supplier.supplier if product_supplier.present?
  end

  def metadata_status
    PurchaseOrder.statuses.key(self.metadata['PoStatus'].to_i).to_s if self.metadata.present?
  end
end
