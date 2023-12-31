class SalesInvoice < ApplicationRecord
  include Mixins::CanBeSynced
  include DisplayHelper
  include Mixins::HasConvertedCalculations
  update_index('sales_invoices') { self }
  update_index('customer_order_status_report') { sales_order }
  update_index('logistics_scorecards') { self }

  pg_search_scope :locate, against: [:id, :invoice_number], associated_against: {company: [:name], account: [:name], inside_sales_owner: [:first_name, :last_name], outside_sales_owner: [:first_name, :last_name]}, using: {tsearch: {prefix: true}}

  belongs_to :sales_order
  has_many :outward_dispatches
  belongs_to :billing_address, class_name: 'Address', required: false
  belongs_to :shipping_address, class_name: 'Address', required: false

  has_one :inquiry, through: :sales_order
  has_one :company, through: :inquiry
  has_one :ar_invoice_request
  has_one :invoice_request

  has_many :credit_notes
  has_many :receipts, class_name: 'SalesReceipt', inverse_of: :sales_invoice
  has_many :packages, class_name: 'SalesPackage', inverse_of: :sales_invoice
  has_many :rows, class_name: 'SalesInvoiceRow', inverse_of: :sales_invoice
  has_many :email_messages
  has_many :sales_receipt_rows
  has_many :sales_receipts, through: :sales_receipt_rows
  has_many :pod_rows, dependent: :destroy
  accepts_nested_attributes_for :pod_rows, reject_if: lambda { |attributes|
    if attributes[:id].present?
      PodRow.find(attributes[:id]).attachments.count < 1
    else
      attributes[:attachments].blank?
    end
  }, allow_destroy: true

  has_one_attached :original_invoice
  has_one_attached :duplicate_invoice
  has_one_attached :triplicate_invoice
  has_one_attached :pod_attachment

  scope :not_cancelled_invoices, -> { where.not(status: 'Cancelled') }
  scope :not_paid, -> { where.not(payment_status: 'Fully Paid') }
  scope :ignore_freight_bm, -> { where.not('sales_invoice_rows.sku = ?', 'BM00008') }
  scope :with_inquiry, -> { where.not(invoice_number: nil) }

  enum status: {
      'Invoiced': 1,
      'Paid': 2,
      'Cancelled': 3,
      'Partial: Shipped': 201,
      'Shipped': 202,
      'Material Delivery Delayed': 203,
      'Delivered: GRN Pending': 204,
      'Delivered: GRN Delayed': 205,
      'Material Ready For Dispatch': 206,
      'Material Rejected': 207,
      'Credit Note Issued: Partial': 208,
      'Credit Note Issued: Full': 209
  }

  enum main_summary_status: {
      # AR Invoice
      'Invoiced': 1,
      'Paid': 2,
      'Material Ready for Dispatch': 206
  }, _suffix: true

  enum delay_reason: {
      'Logistics Delivery Delay': 10,
      'Supplier PO Creation Delay': 20,
      'Supplier Delay': 30,
      'Reason Pending': 40
  }

  enum sla_bucket: {
      'On or before Time': 1,
      'Delayed': 2
  }

  enum delay_bucket: {
      'No delay': 1,
      'Delay by 2 days': 2,
      'Delay by 2-7 days': 3,
      'Delay by 7-14 days': 4,
      'Delay by 14-28 days': 5,
      'Delay by >28 days': 6,
      'Not Delivered': 7
  }, _prefix: true

  scope :with_includes, -> { includes(:sales_order) }
  scope :not_cancelled, -> { where.not(status: 'Cancelled') }
  scope :cancelled, -> { where(status: 'Cancelled') }

  validates_with FileValidator, attachment: :original_invoice, file_size_in_megabytes: 2
  validates_with FileValidator, attachment: :duplicate_invoice, file_size_in_megabytes: 2
  validates_with FileValidator, attachment: :triplicate_invoice, file_size_in_megabytes: 2
  validates_presence_of :invoice_number
  validates_uniqueness_of :invoice_number

  def self.by_number(number)
    find_by_invoice_number(number)
  end

  def get_number
    self.invoice_number
  end

  def filename(include_extension: false)
    [
        ['invoice', invoice_number].join('_'),
        ('pdf' if include_extension)
    ].compact.join('.')
  end

  def zipped_filename(include_extension: false)
    [
        ['invoices', invoice_number].join('_'),
        ('zip' if include_extension)
    ].compact.join('.')
  end

  def serialized_billing_address
    billing_address || sales_order&.inquiry&.billing_address
  end

  def serialized_shipping_address
    shipping_address || sales_order&.inquiry&.shipping_address
  end

  def self.syncable_identifiers
    [:invoice_number]
  end

  def calculated_total
    if credit_notes.present?
      credit_notes.map(&:matched_row_total).sum
    else
      rows.map { |row| (row.metadata['base_row_total'].to_f * row.sales_invoice.metadata['base_to_order_rate'].to_f) }.sum.round(2)
    end
  end

  def calculated_total_tax
    if credit_notes.present?
      credit_notes.map(&:matched_row_total_tax).sum
    else
      rows.map { |row| (row.metadata['base_tax_amount'].to_f * row.sales_invoice.metadata['base_to_order_rate'].to_f) }.sum.round(2)
    end
  end

  def calculated_total_with_tax
    (calculated_total.to_f + calculated_total_tax.to_f).round(2)
  end

  def has_attachment?
    (self.pod_rows.present? && self.pod_rows.order(:delivery_date).last.attachments.attached? && self.delivery_completed) || self.is_manual_closed
  end

  def total_quantity_delivered
    self.rows.where.not(sku: Settings.product_specific.freight).sum(&:quantity)
  end

  def outward_dispatched_quantity
    self.outward_dispatches.sum(&:quantity_in_payment_slips)
  end

  def pod_status
    if is_manual_closed
      'complete'
    elsif self.pod_rows.present? && (self.pod_rows.order(:delivery_date).last.attachments.attached?)
      if self.delivery_completed
        'complete'
      else
        'partial'
      end
    else
      'incomplete'
    end
  end

  def delivery_date
    if self.pod_rows.present?
      self.pod_rows.order(:delivery_date).last.delivery_date
    end
  end

  # def delivery_date
  #   delivery_date = if self.ar_invoice_request.present? && self.ar_invoice_request.outward_dispatches.present?
  #     self.ar_invoice_request.outward_dispatches.order(material_delivery_date: :desc).last.material_delivery_date
  #   end
  #   if !delivery_date.present? && self.pod_rows.present?
  #     self.pod_rows.order(:delivery_date).last.delivery_date
  #   end
  # end

  def amount_received
    # SalesReceipt.where(:sales_invoice_id => self.id).pluck(:payment_amount_received).compact.sum
    SalesReceiptRow.where('sales_invoice_id': self.id).sum(:amount_received)
  end

  def amount_received_against_invoice
    # SalesReceipt.where(:sales_invoice_id => self.id,:payment_type => 'Against Invoice').pluck(:payment_amount_received).compact.sum
    SalesReceiptRow.where('sales_invoice_id': self.id).sum(:amount_received)
  end

  # Not needed, there won't be any on account payment for invoice

  # def amount_received_on_account
  #   SalesReceipt.where(:sales_invoice_id => self.id,:payment_type => 'On Account').pluck(:payment_amount_received).compact.sum
  # end

  def get_due_date
    due_in_days = 30
    if self.inquiry.present? && self.inquiry.payment_option.present?
      due_in_days = self.inquiry.payment_option.get_days
    end
    self.created_at + due_in_days.days
  end

  def get_due_days
    days = '-'
    amount_due = self.amount_due
    if due_date.present? && due_date < Date.today && self.amount_due > 0.0
      if due_date.present?
        if self.amount_received < amount_due
          days = "#{((Time.now - self.get_due_date) / 86400).to_i} days"
        end
      end
    end
    days
  end

  def amount_due
    self.calculated_total_with_tax - self.amount_received
  end

  def overdue_amount
    self.due_date < DateTime.now ? self.amount_due : 0.0
  end

  def nodue_amount
    self.due_date > DateTime.now ? self.amount_due : 0.0
  end

  def overdue_amt_in_days(start_day, end_day = nil)
    due_date = self.due_date
    todays_date = DateTime.now
    due_amt = 0.0
    if due_date < todays_date
      due_days = ((Time.now - due_date) / 86400).to_i
      if end_day.present?
        due_amt = (start_day..end_day).include?(due_days) ? self.amount_due.to_s : 0.0
      else
        due_amt = (due_days > start_day) ? self.amount_due : 0.0
      end
    end
    due_amt
  end

  def nodue_amt_in_days(start_day, end_day = nil)
    due_date = self.due_date
    todays_date = DateTime.now
    due_amt = 0.0
    if due_date > todays_date
      due_days = ((due_date - Time.now) / 86400).to_i
      p due_days
      if end_day.present?
        due_amt = (start_day..end_day).include?(due_days) ? self.amount_due.to_s : 0.0
      else
        due_amt = (due_days > start_day) ? self.amount_due : 0.0
      end
    end
    due_amt
  end

  def calculated_freight_cost_total
    self.rows.sum(&:freight_cost_subtotal).round(2)
  end

  # ====================================== Do not Remove =================================================
  # def calculated_committed_delivery_tat
  #   if [143, 725, 1444, 1392].include?(self.inquiry.company.id)
  #     if self.created_at.present? && self.inquiry.customer_order_date.present?
  #       (self.created_at.to_date - self.inquiry.customer_order_date).to_i
  #     end
  #   else
  #     if self.inquiry.customer_committed_date.present? && self.inquiry.customer_order_date.present?
  #       (self.inquiry.customer_committed_date - self.inquiry.customer_order_date).to_i
  #     end
  #   end
  # end
  # ======================================================================================================

  def calculated_committed_delivery_tat
    if self.sales_order.revised_committed_delivery_date.present? && self.inquiry.customer_order_date.present?
      (self.sales_order.revised_committed_delivery_date - self.inquiry.customer_order_date).to_i
    elsif self.inquiry.customer_committed_date.present? && self.inquiry.customer_order_date.present?
      (self.inquiry.customer_committed_date - self.inquiry.customer_order_date).to_i
    end
  end

  # ====================================== Do not Remove =================================================
  # def calculated_actual_delivery_tat
  #   if [143, 725, 1444, 1392].include?(self.inquiry.company.id)
  #     if self.created_at.present? && self.inquiry.customer_order_date.present?
  #       (self.created_at.to_date - self.inquiry.customer_order_date).to_i
  #     end
  #   else
  #     if self.delivery_date.present? && self.inquiry.customer_order_date.present?
  #       (self.delivery_date - self.inquiry.customer_order_date).to_i
  #     end
  #   end
  # end
  # ======================================================================================================

  def calculated_actual_delivery_tat
    if self.delivery_date.present? && self.inquiry.customer_order_date.present?
      (self.delivery_date - self.inquiry.customer_order_date).to_i
    end
  end

  def calculated_delay
    if self.calculated_committed_delivery_tat.present? && self.calculated_actual_delivery_tat.present?
      (self.calculated_actual_delivery_tat - self.calculated_committed_delivery_tat).to_i
    end
  end

  def calculated_sla_bucket
    if !self.calculated_delay.nil?
      if self.calculated_delay <= 0
        'On or before Time'
      else
        'Delayed'
      end
    end
  end

  def set_delay_for_nil_delivery_date
    if self.sales_order.revised_committed_delivery_date.present?
      self.delivery_date.nil? && (Date.today > self.sales_order.revised_committed_delivery_date)
    elsif self.inquiry.customer_committed_date.present?
      self.delivery_date.nil? && (Date.today > self.inquiry.customer_committed_date)
    end
  end

  def calculated_delay_bucket
    if !self.calculated_delay.nil?
      if self.calculated_delay <= 0
        1
      elsif self.calculated_delay <= 2
        2
      elsif self.calculated_delay <= 7
        3
      elsif self.calculated_delay <= 14
        4
      elsif self.calculated_delay <= 28
        5
      else
        6
      end
    elsif self.set_delay_for_nil_delivery_date
      7
    end
  end

  def to_s
    self.invoice_number
  end

  def total_quantity
    self.rows.sum(&:quantity).to_i
  end

  def cosr_calculate_time_delay
    if self.delivery_date.present? && self.sales_order.revised_committed_delivery_date.present?
      ((self.delivery_date.to_time.to_i - self.sales_order.revised_committed_delivery_date.to_time.to_i) / 60.0).ceil.abs
    elsif self.delivery_date.present? && self.inquiry.customer_committed_date.present?
      ((self.delivery_date.to_time.to_i - self.inquiry.customer_committed_date.to_time.to_i) / 60.0).ceil.abs
    end
  end

  def self.get_invoice_count(overseer, date_range)
    if date_range.present?
      from = date_range.split('~').first.to_date.beginning_of_day.strftime('%d-%m-%Y')
      to = date_range.split('~').last.to_date.end_of_day.strftime('%d-%m-%Y')
      overseer_role = overseer.role == 'inside_sales_executive' ? 'inside_sales_owner_id' : 'outside_sales_owner_id'
      invoices = SalesInvoice.joins(:inquiry).where(mis_date: from..to).where(inquiries: {"#{overseer_role}": overseer.id})
      invoice_count = invoices.count
      revenue = invoices.map { |invoice| invoice.calculated_total }.compact.sum
      [invoice_count, revenue]
    end
  end

  def get_bill_from_warehouse
    metadata = self.metadata.deep_symbolize_keys
    if metadata[:bill_from].present?
      bill_from_warehouse = Warehouse.find_by_remote_uid(metadata[:bill_from])
    else
      inquiry = self.inquiry
      bill_from_warehouse = inquiry.bill_from
    end

    bill_from_warehouse
  end


  def get_contact_for_email
    [self.inquiry.billing_contact.email, self.inquiry.shipping_contact.email].uniq.join(',')
  end

  def calculate_tcs_amount
    if self.company.check_company_total_amount(self)
      self.metadata['tcs_amount'].present? ? self.metadata['tcs_amount'].to_f : 0.0
      # ((self.metadata['base_subtotal_incl_tax'].to_f / self.metadata['base_to_order_rate'].to_f) * (0.075 / 100))
    end
  end

  def credit_memo_amount
    credit_notes.present? ? credit_notes.first.memo_amount.to_f : 0.0
  end

  def net_amount
    metadata['base_grand_total'].to_f - metadata['base_tax_amount'].to_f
  end

  def tax_amount
    metadata['base_tax_amount'].to_f
  end

  def self.total_net_amount
    where.not(status: [:Cancelled, :'Credit Note Issued: Full']).sum(&:net_amount)
  end

  def self.total_tax_amount
    where.not(status: [:Cancelled, :'Credit Note Issued: Full']).sum(&:tax_amount)
  end

  def self.total_of_total_amount
    total_sum = 0.0

    all_sales_invoices = self.where.not(status: [:Cancelled, :'Credit Note Issued: Full'])
    all_sales_invoices.each do |sales_invoice|
      total_amount = (sales_invoice.net_amount + sales_invoice.tax_amount) - sales_invoice.credit_memo_amount
      total_sum += total_amount
    end

    total_sum
  end
end
