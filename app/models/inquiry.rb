class Inquiry < ApplicationRecord
  COMMENTS_CLASS = 'InquiryComment'

  include Mixins::CanBeStamped
  # include Mixins::HasAddresses
  include Mixins::CanBeSynced
  include Mixins::HasManagers
  include Mixins::HasComments

  update_index('inquiries#inquiry') { self }
  pg_search_scope :locate, against: [:id, :inquiry_number], associated_against: { company: [:name], account: [:name], contact: [:first_name, :last_name], inside_sales_owner: [:first_name, :last_name], outside_sales_owner: [:first_name, :last_name] }, using: { tsearch: { prefix: true } }

  belongs_to :inquiry_currency, dependent: :destroy
  has_one :currency, through: :inquiry_currency
  # belongs_to :contact, -> (record) { joins(:company_contacts).where('company_contacts.company_id = ?', record.company_id) }
  belongs_to :contact, required: false
  belongs_to :company
  belongs_to :billing_company, -> (record) { where('id in (?)', record.account.companies.pluck(:id)) }, class_name: 'Company', foreign_key: 'billing_company_id'
  belongs_to :shipping_company, -> (record) { where('id in (?)', record.account.companies.pluck(:id)) }, class_name: 'Company', foreign_key: 'shipping_company_id'
  belongs_to :shipping_contact, class_name: 'Contact', foreign_key: 'shipping_contact_id'
  has_one :account, through: :company
  has_one :industry, through: :company
  belongs_to :bill_from, class_name: 'Warehouse', foreign_key: :bill_from_id, required: false
  belongs_to :ship_from, class_name: 'Warehouse', foreign_key: :ship_from_id, required: false
  has_one :account, through: :company
  has_many :inquiry_products, -> { order(sr_no: :asc) }, inverse_of: :inquiry, dependent: :destroy
  accepts_nested_attributes_for :inquiry_products, reject_if: lambda { |attributes| attributes['product_id'].blank? && attributes['id'].blank? }, allow_destroy: true
  belongs_to :payment_option, required: false
  belongs_to :billing_address, -> (record) { where(company_id: record.company.id) }, class_name: 'Address', foreign_key: :billing_address_id, required: false
  belongs_to :shipping_address, class_name: 'Address', foreign_key: :shipping_address_id, required: false
  has_many :products, through: :inquiry_products
  has_many :approvals, through: :products, class_name: 'ProductApproval'
  has_many :inquiry_product_suppliers, through: :inquiry_products
  has_many :brands, through: :products
  has_many :suppliers, through: :inquiry_product_suppliers
  has_many :imports, class_name: 'InquiryImport', inverse_of: :inquiry
  has_many :sales_quotes, dependent: :destroy
  has_many :purchase_orders
  has_many :po_requests
  accepts_nested_attributes_for :po_requests, allow_destroy: true
  has_many :sales_quote_rows, through: :sales_quotes
  has_one :final_sales_quote, -> { where.not(sent_at: nil).latest }, class_name: 'SalesQuote'
  has_many :draft_sales_quotes, -> { where(sent_at: nil) }, class_name: 'SalesQuote'
  has_many :final_sales_orders, through: :final_sales_quote, class_name: 'SalesOrder'
  has_one :approved_final_sales_order, -> { approved }, through: :final_sales_quote, class_name: 'SalesOrder'
  has_one :sales_quote, -> { latest }
  has_many :sales_orders, through: :sales_quotes, dependent: :destroy
  has_many :shipments, through: :sales_orders, class_name: 'SalesShipment', source: :shipments
  has_many :invoices, through: :sales_orders, class_name: 'SalesInvoice'
  has_many :sales_order_rows, through: :sales_orders
  has_many :final_sales_orders, -> { where.not(sent_at: nil).latest }, through: :final_sales_quote, class_name: 'SalesOrder', source: :sales_orders
  has_many :email_messages, dependent: :destroy
  has_many :activities, dependent: :nullify
  has_many :inquiry_status_records
  belongs_to :legacy_shipping_company, -> (record) { where(company_id: record.company.id) }, class_name: 'Company', foreign_key: :legacy_shipping_company_id, required: false
  belongs_to :legacy_bill_to_contact, class_name: 'Contact', foreign_key: :legacy_bill_to_contact_id, required: false
  has_one :customer_order, dependent: :nullify
  has_one :freight_request

  has_one_attached :customer_po_sheet
  has_one_attached :copy_of_email
  has_one_attached :supplier_quote
  has_many_attached :supplier_quotes
  has_one_attached :final_supplier_quote
  has_one_attached :calculation_sheet

  enum status: {
      'Lead by O/S': 11,
      'New Inquiry': 0,
      'Acknowledgement Mail': 2,
      'Cross Reference': 3,
      'Supplier RFQ Sent': 12,
      'Preparing Quotation': 4,
      'Quotation Sent': 5,
      'Follow Up on Quotation': 6,
      'Expected Order': 7,
      'SO Not Created-Customer PO Awaited': 13,
      'SO Not Created-Pending Customer PO Revision': 14,
      'Draft SO for Approval by Sales Manager': 15,
      'SO Draft: Pending Accounts Approval': 8,
      'Order Won': 18,
      'SO Rejected by Sales Manager': 17,
      'Rejected by Accounts': 19,
      'Hold by Accounts': 20,
      'Order Lost': 9,
      'Regret': 10,
  }

  def regrettable_statuses
    Inquiry.statuses.keys.sort.reject { |status| ['Order Lost', 'Regret', 'Expected Order'].include?(status) }
  end

  enum stage: {
      inquiry_number_assigned: 1,
      prepare_quotation: 5,
      quotation_sent: 6,
      sales_order_approved: 92
  }

  enum opportunity_type: {
      amazon: 10,
      rate_contract: 20,
      financing: 30,
      regular: 40,
      service: 50,
      repeat: 60,
      list: 65,
      route_through: 70,
      tender: 80,
      stock: 90
  }

  enum opportunity_source: {
      unsure: 5,
      meeting: 10,
      phone_call: 20,
      email: 30,
      quote_tender_prep: 40
  }

  enum quote_category: {
      bmro: 10,
      ong: 20
  }

  enum price_type: {
      'EXW': 10,
      'FOB': 20,
      'CIF': 30,
      'CFR': 40,
      'DAP': 50,
      'Door delivery': 60,
      'FCA Mumbai': 70,
      'CIP': 80,
      'CIP Mumbai airport': 100
  }

  enum freight_option: {
      'Included': 10,
      'Extra': 20
  }, _prefix: true

  enum packing_and_forwarding_option: {
      'Included': 10,
      'Extra': 20
  }

  def commercial_status
    :open
  end

  scope :with_includes, -> { includes(:created_by, :updated_by, :contact, :inside_sales_owner, :outside_sales_owner, :company, :account, final_sales_quote: [rows: [:inquiry_product_supplier]]) }
  scope :smart_queue, -> {
    where('status NOT IN (?)', [
        Inquiry.statuses[:'Lead by O/S'],
        Inquiry.statuses[:'Order Lost'],
        Inquiry.statuses[:'Regret']
    ]).order(priority: :desc, quotation_followup_date: :asc, calculated_total: :desc)
  }
  scope :won, -> { where(status: :'Order Won') }

  attr_accessor :force_has_sales_orders, :common_supplier_id, :select_all_products, :select_all_suppliers

  with_options if: :has_sales_orders_and_not_legacy? do |inquiry|
    # inquiry.validates_with FilePresenceValidator, attachment: :customer_po_sheet
    inquiry.validates_with FilePresenceValidator, attachment: :calculation_sheet
    # inquiry.validates_with MultipleFilePresenceValidator, attachments: :supplier_quotes
    inquiry.validates_presence_of :customer_po_number
    inquiry.validates_presence_of :customer_order_date
    inquiry.validates_presence_of :customer_committed_date
  end

  def has_sales_orders_and_not_legacy?
    (self.sales_orders.present? || self.force_has_sales_orders == true) && not_legacy?
  end

  def valid_for_new_sales_order?
    self.force_has_sales_orders = true
    self.valid?
  end

  # validates_with FileValidator, attachment: :customer_po_sheet, file_size_in_megabytes: 2
  # validates_with FileValidator, attachment: :copy_of_email, file_size_in_megabytes: 2
  # validates_with FileValidator, attachment: :supplier_quote, file_size_in_megabytes: 2
  # validates_with MultipleFileValidator, attachments: :supplier_quotes, file_size_in_megabytes: 2
  # validates_with FileValidator, attachment: :final_supplier_quote, file_size_in_megabytes: 2
  validates_with FileValidator, attachment: :calculation_sheet, file_size_in_megabytes: 2

  validates_numericality_of :gross_profit_percentage, greater_than_equal_to: 0, less_than_or_equal_to: 100, allow_nil: true
  validates_numericality_of :potential_amount, greater_than: 0.00, if: :not_legacy?

  # validates_uniqueness_of :subject, :if => :not_legacy?
  validates_presence_of :inquiry_currency
  validates_presence_of :company
  validates_presence_of :expected_closing_date, if: :not_legacy?
  validates_presence_of :valid_end_time, if: :not_legacy?
  validates_presence_of :inside_sales_owner, if: :not_legacy?
  validates_presence_of :outside_sales_owner, if: :not_legacy?
  validates_presence_of :potential_amount, if: :not_legacy?
  validates_presence_of :quote_category, if: :not_legacy?
  validates_presence_of :payment_option, if: :not_legacy?
  validates_presence_of :billing_address, if: :not_legacy?
  validates_presence_of :billing_company, if: :not_legacy?
  validates_presence_of :shipping_address, if: :not_legacy?
  validates_presence_of :shipping_company, if: :not_legacy?
  validates_presence_of :contact, if: :not_legacy?

  validate :every_product_is_only_added_once?

  validate :company_is_active, if: :new_record?

  def company_is_active
    if !self.company.is_active
      errors.add(:company, 'must be active to make a inquiry')
    end
  end

  def every_product_is_only_added_once?
    if self.inquiry_products.uniq { |ip| ip.product_id }.size != self.inquiry_products.size
      errors.add(:inquiry_products, 'every product can only be included once in a particular inquiry')
    end
  end

  def syncable_identifiers
    [:project_uid, :opportunity_uid]
  end

  after_initialize :set_defaults, if: :new_record?

  def set_defaults
    if self.created_by.present?
      self.inside_sales_owner ||= self.created_by
    end

    if self.company.present?
      self.inside_sales_owner ||= self.company.inside_sales_owner if not_legacy?
      self.outside_sales_owner ||= self.company.outside_sales_owner if not_legacy?
      self.sales_manager ||= self.company.sales_manager if not_legacy?
      self.status ||= :'New Inquiry'
      self.opportunity_type ||= :regular
      self.opportunity_source ||= :unsure
      self.quote_category ||= :bmro
      self.potential_amount ||= 0.0
      self.price_type ||= :"EXW"
      self.freight_option ||= :"Included"
      self.packing_and_forwarding_option ||= :"Included"
      self.expected_closing_date ||= (Date.today + 1.day) if self.not_legacy?
      self.valid_end_time ||= (Date.today + 1.month) if self.not_legacy?
      self.freight_cost ||= 0
      self.contact ||= self.company.default_company_contact.contact if self.company.default_company_contact.present?
      self.shipping_contact ||= self.company.default_company_contact.contact if self.company.default_company_contact.present?
      self.payment_option ||= self.company.default_payment_option
      self.billing_address ||= self.company.default_billing_address
      self.shipping_address ||= self.company.default_shipping_address
      self.bill_from ||= Warehouse.default
      self.ship_from ||= Warehouse.default
      self.commercial_terms_and_conditions ||= [
          '1. Cost does not include any additional certification if required as per Indian regulations.',
          '2. Any errors in quotation including HSN codes, GST Tax rates must be notified before placing order.',
          '3. Order once placed cannot be changed.',
          '4. BulkMRO does not accept any financial penalties for late deliveries.'
      ].join("\r\n") if not_legacy?
      self.stage ||= 1
    end

    self.is_sez ||= false
    self.inquiry_currency ||= self.build_inquiry_currency

    if self.company.present? && (self.billing_company.blank? || self.shipping_company.blank?)
      self.billing_company ||= self.company
      self.shipping_company ||= self.company
    end
  end

  def draft?
    !inquiry_products.any?
  end

  def inquiry_products_for(supplier)
    self.inquiry_products.joins(:inquiry_product_suppliers).where('inquiry_product_suppliers.supplier_id = ?', supplier.id)
  end

  def attachments
    attachment = []
    attachment.push(self.customer_po_sheet) if self.customer_po_sheet.attached?
    attachment.push(self.copy_of_email) if self.copy_of_email.attached?
    attachment.push(self.supplier_quotes.attachments) if self.supplier_quotes.attached?
    attachment.push(self.final_supplier_quote) if self.final_supplier_quote.attached?
    attachment.push(self.calculation_sheet) if self.calculation_sheet.attached?
    attachment.compact
  end

  def suppliers_selected?
    self.inquiry_product_suppliers.persisted.present?
  end

  def terms
    commercial_terms_and_conditions
  end

  def terms_lines
    terms ? terms.split(/[\r\n]+/) : []
  end

  def can_be_managed?(overseer)
    overseer.manager? || overseer.self_and_descendant_ids.include?(self.inside_sales_owner_id) || overseer.self_and_descendant_ids.include?(self.outside_sales_owner_id) || overseer.self_and_descendant_ids.include?(self.created_by_id) || false
  end

  def last_sr_no
    self.inquiry_products.maximum(:sr_no) || 0
  end

  def to_s
    [
        ['#', self.inquiry_number].join,
        self.company.name
    ].join(' ')
  end

  def po_subject
    if self.customer_po_number.present?
      if self.customer_po_number != ''
        self.customer_po_number.strip.empty? ? self.subject : [self.customer_po_number, self.subject].join(' - ')
      else
        self.subject
      end
    else
      self.subject
    end
  end

  def billing_contact
    self.contact
  end

  def has_attachment?
    self.customer_po_sheet.attached? || self.copy_of_email.attached? || self.supplier_quotes.attached? || self.final_supplier_quote.attached? || self.calculation_sheet.attached?
  end

  def remote_shipping_address_uid
    self.billing_company == self.shipping_company ? self.shipping_address.remote_uid : self.billing_address.remote_uid
  end

  def remote_shipping_company_uid
    if self.shipping_company.present?
      self.billing_company == self.shipping_company ? self.billing_company.remote_uid : self.shipping_company.remote_uid
    else
      self.billing_company.remote_uid
    end
  end

  def potential_value(status)
    case status
      when 'Lead by O/S', 'New Inquiry', 'Acknowledgement Mail'
        self.potential_amount || 0.0
      when 'Cross Reference'
        self.products.map(&:latest_unit_cost_price).compact.sum || 0.0
      when 'Preparing Quotation'
        self.draft_sales_quotes.map(&:calculated_total).compact.sum || 0.0
      when 'Quotation Sent', 'Follow-Up on Quotation', 'Expected Order', 'SO Not Created-Customer PO Awaited', 'SO Not Created-Pending Customer PO Revision'
        self.final_sales_quote.try(:calculated_total) || 0.0
      when 'Order Won'
        self.final_sales_orders.remote_approved.map(&:calculated_total).sum || 0.0
      when 'Draft SO For Approval by Sales Manager', 'SO Draft: Pending Accounts Approval', 'SO Rejected by Sales Manager', 'Rejected by Accounts'
        self.sales_orders.map(&:calculated_total).compact.sum || 0.0
      when 'Order Lost'
        (self.final_sales_quote.try(:calculated_total) || 0.0) + (self.final_sales_orders.last.try(&:calculated_total) || 0.0) + (self.products.map(&:latest_unit_cost_price).compact.sum || 0.0)
      when 'Regret'
        self.final_sales_quote.try(:calculated_total) || 0.0
      else
        0
    end
  end

  def margin_percentage
    self.final_sales_quote.present? ? self.final_sales_quote.calculated_total_margin_percentage.to_f : 0
  end

  def update_last_synced_quote
    self.update_attributes(last_synced_quote_id: self.final_sales_quote.id) if self.final_sales_quote.present?
  end
end
