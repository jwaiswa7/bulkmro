class InwardDispatch < ApplicationRecord
  COMMENTS_CLASS = 'InwardDispatchComment'

  include Mixins::HasComments
  include Mixins::CanBeStamped
  include Mixins::GetOverallDate

  update_index('inward_dispatches#inward_dispatch') { self }
  belongs_to :purchase_order
  has_one :inquiry, through: :purchase_order

  attr_accessor :common_supplier_delivery_date

  belongs_to :logistics_owner, -> (record) { where(role: 'logistics') }, class_name: 'Overseer', foreign_key: 'logistics_owner_id', optional: true
  has_many :rows, -> { joins(:purchase_order_row) }, class_name: 'InwardDispatchRow', inverse_of: :inward_dispatch, dependent: :destroy
  has_many_attached :attachments
  belongs_to :invoice_request, optional: true
  belongs_to :ar_invoice_request, optional: true
  belongs_to :sales_order, optional: true
  accepts_nested_attributes_for :rows, reject_if: lambda { |attributes| attributes['purchase_order_row_id'].blank? && attributes['id'].blank? }, allow_destroy: true
  validates_associated :rows
  enum document_types: {
      'Tax Invoice': 10,
      'Proforma Invoice': 20,
      'Delivery Challan': 30
  }

  enum status: {
      'Material Pickup': 10,
      'Material Delivered': 20,
      'GRPO Request Rejected': 30,
      'GRPO Pending': 35,
      'AP Invoice Request Rejected': 40,
      'AR Invoice requested': 10,
      'Cancelled AR Invoice': 20,
      'AR Invoice Request Rejected': 30,
      'Completed AR Invoice Request': 40,
      'Material Ready for Dispatch': 50,
      'Dispatch Approval Pending': 60,
      'Dispatch Rejected': 70,
      'Material In Transit': 80,
      'Material Delivered Pending GRN': 90,
  }

  enum ar_invoice_request_status: {
      'Not Requested': 10,
      'Partially Completed': 20,
      'Invoiced': 30,
      'Fully Cancelled': 40,
  }

  # enum outward_status: {
  #     'AR Invoice requested': 10,
  #     'Cancelled AR Invoice': 20,
  #     'AR Invoice Request Rejected': 30,
  #     'Completed AR Invoice Request': 40,
  #     'Material Ready for Dispatch': 50,
  #     'Dispatch Approval Pending': 60,
  #     'Dispatch Rejected': 70,
  #     'Material In Transit': 80,
  #     'Material Delivered Pending GRN': 90,
  #     'Material Delivered': 100
  # }


  enum dispatched_bies: {
      'Supplier': 10,
      'Bulk MRO': 20
  }

  enum shipped_tos: {
      'BM Warehouse': 10,
      'Customer Warehouse': 20
  }

  enum logistics_partners: {
      'Aramex': 1,
      'FedEx': 2,
      'Spoton': 3,
      'Safe Xpress': 4,
      'Professional Couriers': 5,
      'DTDC': 5,
      'Delhivery': 7,
      'UPS': 8,
      'Blue Dart': 9,
      'Anjani Courier': 10,
      'Mahavir Courier Services': 11,
      'Elite Enterprise': 12,
      'Sri Krishna Logistics': 13,
      'Maruti Courier': 14,
      'Vinod': 20,
      'Ganesh': 21,
      'Tushar': 22,
      'Others': 40,
      'Drop Ship': 60
  }

  enum logistics_aggregator: {
      'PS Enterprises': 10,
      'Elite Enterprise': 20
  }, _prefix: true

  scope :with_includes, -> { includes(:inquiry).includes(:purchase_order) }
  scope :'3PL', -> { where(logistics_partner: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]) }
  scope :'BM Runner', -> { where(logistics_partner: [20, 21, 22]) }
  after_initialize :set_defaults, if: :new_record?

  validates_length_of :rows, minimum: 1, message: 'must have at least one product', on: :update
  validates :attachments, presence: true, if: :material_delivered?
  validates :document_type, presence: true, if: :attachments?
  validate :date_validation

  def grouped_status
    grouped_status = {}
    status_category = { 1 => '3PL', 20 => 'BM Runner', 40 => 'Others', 60 => 'Drop Ship' }
    status_category.each do |index, category|
      grouped_status[category] = InwardDispatch.logistics_partners.collect { |status, v|
        if v.between?(index, index + 13)
          status
        end}.compact
    end
    grouped_status
  end

  def material_delivered?
    status == 'Material Delivered'
  end

  def is_inward_completed?
    self.invoice_request.present? && (self.invoice_request.status == 'Inward Completed')
  end

  def po_row_size
    purchase_order.rows.size
  end

  def show_supplier_delivery_date
    get_overall_date(self)
  end

  # @return [Boolean]
  def attachments?
    attachments.any? || material_delivered?
  end

  def date_validation
    errors[:expected_delivery_date] << ' Cannot be less than Expected Dispatch Date' if self[:expected_delivery_date] < self[:expected_dispatch_date]
  end

  def set_defaults
    self.expected_delivery_date = purchase_order.po_request.supplier_committed_date if purchase_order.po_request.present?
  end

  def calculative_ar_invoice_req_status
    if self.sales_order.present?
      product_ids_array = self.rows.pluck(:product_id).uniq
      ar_invoce_rows = ArInvoiceRequestRow.where(sales_order_id: self.sales_order.id, product_id: product_ids_array)
      if ar_invoce_rows.pluck(:ar_invoice_request_id).length > 0
        sales_order_rows =  SalesOrderRow.where(sales_order_id: self.sales_order_id, product_id: product_ids_array)
        total_quantity = sales_order_rows.sum(&:quantity)
        ar_invoce_rows = ArInvoiceRequestRow.where(sales_order_id: self.sales_order.id, product_id: product_ids_array)
        ar_invoce_rows_without_cancelled = ar_invoce_rows.joins(:ar_invoice_request).where.not(ar_invoice_requests: {status: "Cancelled AR Invoice"})
        delivered_quantity = ar_invoce_rows_without_cancelled.sum(&:delivered_quantity)
        if total_quantity != delivered_quantity
          if ar_invoce_rows_without_cancelled.length == 0
            'Fully Cancelled'
          else
            'Partially Completed'
          end
        else
          'Invoiced'
        end
      else
        'Not Requested'
      end
    end
  end

  def show_ar_invoice_requests
    product_ids_array = self.rows.pluck(:product_id).uniq
    ar_invoices = ArInvoiceRequest.joins(:rows).where(ar_invoice_request_rows: {sales_order_id: self.sales_order.id, product_id: product_ids_array})
  end

  def set_outward_status
    if self.ar_invoice_request.present?
      ar_invoice_request = self.ar_invoice_request
      outward_dispatches = OutwardDispatch.where(id: ar_invoice_request.id).order(:updated_at)
      if !outward_dispatches.empty?
        outward_dispatch_status = outward_dispatches.pluck(:status).last
        self.update_attribute(:status, outward_dispatch_status)
      else
        ar_invoice_request_status = ar_invoice_request.status
        self.update_attribute(:status, ar_invoice_request_status)
      end
    end

  end

  def readable_status
    [status, 'Request'].join(' ')
  end

  # def to_s
  #   [readable_status, "##{self.id}"].join(' ')
  # end
end
