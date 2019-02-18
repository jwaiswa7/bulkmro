# frozen_string_literal: true

class Inquiry < ApplicationRecord
  COMMENTS_CLASS = 'InquiryComment'

  include Mixins::CanBeStamped
  # include Mixins::HasAddresses
  include Mixins::CanBeSynced
  include Mixins::HasManagers
  include Mixins::HasComments

  update_index('inquiries#inquiry') { self }
  pg_search_scope :locate, against: %i[id inquiry_number], associated_against: { company: [:name], account: [:name], contact: %i[first_name last_name], inside_sales_owner: %i[first_name last_name], outside_sales_owner: %i[first_name last_name] }, using: { tsearch: { prefix: true } }

  belongs_to :inquiry_currency, dependent: :destroy
  has_one :currency, through: :inquiry_currency
  # belongs_to :contact, -> (record) { joins(:company_contacts).where('company_contacts.company_id = ?', record.company_id) }
  belongs_to :contact, required: false
  belongs_to :company
  belongs_to :billing_company, ->(record) { where('id in (?)', record.account.companies.pluck(:id)) }, class_name: 'Company', foreign_key: 'billing_company_id'
  belongs_to :shipping_company, ->(record) { where('id in (?)', record.account.companies.pluck(:id)) }, class_name: 'Company', foreign_key: 'shipping_company_id'
  belongs_to :shipping_contact, class_name: 'Contact', foreign_key: 'shipping_contact_id'
  has_one :account, through: :company
  has_one :industry, through: :company
  belongs_to :bill_from, class_name: 'Warehouse', foreign_key: :bill_from_id, required: false
  belongs_to :ship_from, class_name: 'Warehouse', foreign_key: :ship_from_id, required: false
  has_one :account, through: :company
  has_many :inquiry_products, -> { order(sr_no: :asc) }, inverse_of: :inquiry, dependent: :destroy
  accepts_nested_attributes_for :inquiry_products, reject_if: ->(attributes) { attributes['product_id'].blank? && attributes['id'].blank? }, allow_destroy: true
  belongs_to :payment_option, required: false
  belongs_to :billing_address, ->(record) { where(company_id: record.company.id) }, class_name: 'Address', foreign_key: :billing_address_id, required: false
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
  has_many :sales_quote_rows, through: :sales_quotes
  has_one :final_sales_quote, -> { where.not(sent_at: nil).latest }, class_name: 'SalesQuote'
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
  belongs_to :legacy_shipping_company, ->(record) { where(company_id: record.company.id) }, class_name: 'Company', foreign_key: :legacy_shipping_company_id, required: false
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
    'SO Not Created-Customer PO Awaited': 13, # TODO: SO not created to order won is all Order Won
    'SO Not Created-Pending Customer PO Revision': 14,
    'Draft SO for Approval by Sales Manager': 15,
    'SO Draft: Pending Accounts Approval': 8,
    'Order Won': 18,
    'SO Rejected by Sales Manager': 17,
    'Rejected by Accounts': 19,
    'Hold by Accounts': 20,
    'Order Lost': 9,
    'Regret': 10
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
    tender: 80
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
  scope :smart_queue, lambda {
    where('status NOT IN (?)', [
            Inquiry.statuses[:'Lead by O/S'],
            Inquiry.statuses[:'Order Lost'],
            Inquiry.statuses[:Regret]
          ]).order(priority: :desc, quotation_followup_date: :asc, calculated_total: :desc)
  }
  scope :won, -> { where(status: :'Order Won') }

  attr_accessor :force_has_sales_orders, :common_supplier_id, :select_all_products, :select_all_suppliers

  with_options if: :has_sales_orders_and_not_legacy? do |inquiry|
    inquiry.validates_with FilePresenceValidator, attachment: :customer_po_sheet
    # inquiry.validates_with FilePresenceValidator, attachment: :calculation_sheet
    inquiry.validates_with MultipleFilePresenceValidator, attachments: :supplier_quotes
    inquiry.validates_presence_of :customer_po_number
    inquiry.validates_presence_of :customer_order_date
    inquiry.validates_presence_of :customer_committed_date
  end

  def has_sales_orders_and_not_legacy?
    (sales_orders.present? || force_has_sales_orders == true) && not_legacy?
  end

  def valid_for_new_sales_order?
    self.force_has_sales_orders = true
    valid?
  end

  validates_with FileValidator, attachment: :customer_po_sheet, file_size_in_megabytes: 2
  validates_with FileValidator, attachment: :copy_of_email, file_size_in_megabytes: 2
  validates_with FileValidator, attachment: :supplier_quote, file_size_in_megabytes: 2
  validates_with MultipleFileValidator, attachments: :supplier_quotes, file_size_in_megabytes: 2
  validates_with FileValidator, attachment: :final_supplier_quote, file_size_in_megabytes: 2
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
    unless company.is_active
      errors.add(:company, 'must be active to make a inquiry')
    end
  end

  def every_product_is_only_added_once?
    if inquiry_products.uniq(&:product_id).size != inquiry_products.size
      errors.add(:inquiry_products, 'every product can only be included once in a particular inquiry')
    end
  end

  def syncable_identifiers
    %i[project_uid opportunity_uid]
  end

  after_initialize :set_defaults, if: :new_record?

  def set_defaults
    self.inside_sales_owner ||= created_by if created_by.present?

    if company.present?
      self.inside_sales_owner ||= company.inside_sales_owner if not_legacy?
      self.outside_sales_owner ||= company.outside_sales_owner if not_legacy?
      self.sales_manager ||= company.sales_manager if not_legacy?
      self.status ||= :'New Inquiry'
      self.opportunity_type ||= :regular
      self.opportunity_source ||= :unsure
      self.quote_category ||= :bmro
      self.potential_amount ||= 0.0
      self.price_type ||= :EXW
      self.freight_option ||= :Included
      self.packing_and_forwarding_option ||= :Included
      self.expected_closing_date ||= (Date.today + 1.day) if not_legacy?
      self.valid_end_time ||= (Date.today + 1.month) if not_legacy?
      self.freight_cost ||= 0
      self.contact ||= company.default_company_contact.contact if company.default_company_contact.present?
      self.shipping_contact ||= company.default_company_contact.contact if company.default_company_contact.present?
      self.payment_option ||= company.default_payment_option
      self.billing_address ||= company.default_billing_address
      self.shipping_address ||= company.default_shipping_address
      self.bill_from ||= Warehouse.default
      self.ship_from ||= Warehouse.default
      if not_legacy?
        self.commercial_terms_and_conditions ||= [
          '1. Cost does not include any additional certification if required as per Indian regulations.',
          '2. Any errors in quotation including HSN codes, GST Tax rates must be notified before placing order.',
          '3. Order once placed cannot be changed.',
          '4. BulkMRO does not accept any financial penalties for late deliveries.'
        ].join("\r\n")
      end
      self.stage ||= 1
    end

    self.is_sez ||= false
    self.inquiry_currency ||= build_inquiry_currency

    if company.present? && (billing_company.blank? || shipping_company.blank?)
      self.billing_company ||= company
      self.shipping_company ||= company
    end
  end

  def draft?
    inquiry_products.none?
  end

  def inquiry_products_for(supplier)
    inquiry_products.joins(:inquiry_product_suppliers).where('inquiry_product_suppliers.supplier_id = ?', supplier.id)
  end

  def attachments
    attachment = []
    attachment.push(customer_po_sheet) if customer_po_sheet.attached?
    attachment.push(copy_of_email) if copy_of_email.attached?
    attachment.push(supplier_quotes.attachments) if supplier_quotes.attached?
    attachment.push(final_supplier_quote) if final_supplier_quote.attached?
    attachment.push(calculation_sheet) if calculation_sheet.attached?
    attachment.compact
  end

  def suppliers_selected?
    inquiry_product_suppliers.persisted.present?
  end

  def terms
    commercial_terms_and_conditions
  end

  def terms_lines
    terms ? terms.split(/[\r\n]+/) : []
  end

  def can_be_managed?(overseer)
    overseer.manager? || overseer.self_and_descendant_ids.include?(inside_sales_owner_id) || overseer.self_and_descendant_ids.include?(outside_sales_owner_id) || overseer.self_and_descendant_ids.include?(created_by_id) || false
  end

  def last_sr_no
    inquiry_products.maximum(:sr_no) || 0
  end

  def to_s
    [
      ['#', inquiry_number].join,
      company.name
    ].join(' ')
  end

  def po_subject
    if customer_po_number.present?
      if customer_po_number != ''
        customer_po_number.strip.empty? ? subject : [customer_po_number, subject].join(' - ')
      else
        subject
      end
    else
      subject
    end
  end

  def billing_contact
    self.contact
  end

  def has_attachment?
    customer_po_sheet.attached? || copy_of_email.attached? || supplier_quotes.attached? || final_supplier_quote.attached? || calculation_sheet.attached?
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
end
