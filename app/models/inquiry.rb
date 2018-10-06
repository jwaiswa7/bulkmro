class Inquiry < ApplicationRecord
  COMMENTS_CLASS = 'InquiryComment'

  include Mixins::CanBeStamped
  #include Mixins::HasAddresses
  include Mixins::CanBeSynced
  include Mixins::HasManagers
  include Mixins::HasComments

  update_index('inquiries#inquiry') {self}
  pg_search_scope :locate, :against => [:id, :inquiry_number], :associated_against => {company: [:name], account: [:name], :contact => [:first_name, :last_name], :inside_sales_owner => [:first_name, :last_name], :outside_sales_owner => [:first_name, :last_name]}, :using => {:tsearch => {:prefix => true}}

  belongs_to :inquiry_currency, dependent: :destroy
  has_one :currency, :through => :inquiry_currency
  # belongs_to :contact, -> (record) { joins(:company_contacts).where('company_contacts.company_id = ?', record.company_id) }
  belongs_to :contact, required: false
  belongs_to :company
  has_one :account, :through => :company
  has_one :industry, :through => :company
  belongs_to :billing_address, -> (record) {where(company_id: record.company.id)}, class_name: 'Address', foreign_key: :billing_address_id, required: :not_legacy?
  belongs_to :shipping_address, -> (record) {where(company_id: record.company.id)}, class_name: 'Address', foreign_key: :shipping_address_id, required: :not_legacy?
  belongs_to :bill_from, class_name: 'Warehouse', foreign_key: :bill_from_id, required: :not_legacy?
  belongs_to :ship_from, class_name: 'Warehouse', foreign_key: :ship_from_id, required: :not_legacy?
  has_one :account, :through => :company
  has_many :inquiry_products, -> {order(sr_no: :asc)}, :inverse_of => :inquiry, dependent: :destroy
  accepts_nested_attributes_for :inquiry_products, reject_if: lambda {|attributes| attributes['product_id'].blank? && attributes['id'].blank?}, allow_destroy: true

  has_many :products, :through => :inquiry_products
  has_many :approvals, :through => :products, :class_name => 'ProductApproval'
  has_many :inquiry_product_suppliers, :through => :inquiry_products
  has_many :brands, :through => :products
  has_many :suppliers, :through => :inquiry_product_suppliers
  has_many :imports, :class_name => 'InquiryImport', inverse_of: :inquiry
  has_many :sales_quotes, dependent: :destroy
  has_many :sales_quote_rows, :through => :sales_quotes
  has_one :final_sales_quote, -> {where.not(:sent_at => nil).latest}, class_name: 'SalesQuote'
  has_one :sales_quote, -> {latest}
  has_many :sales_orders, :through => :sales_quotes
  has_many :sales_order_rows, :through => :sales_orders
  has_many :final_sales_orders, -> {where.not(:sent_at => nil).latest}, :through => :final_sales_quote, class_name: 'SalesOrder', source: :sales_orders
  belongs_to :payment_option, required: :not_legacy?
  has_many :email_messages
  has_many :activities, dependent: :nullify

  belongs_to :legacy_shipping_company, -> (record) {where(company_id: record.company.id)}, class_name: 'Company', foreign_key: :legacy_shipping_company_id, required: false
  belongs_to :legacy_bill_to_contact, class_name: 'Contact', foreign_key: :legacy_bill_to_contact_id, required: false

  has_one_attached :customer_po_sheet
  has_one_attached :copy_of_email
  has_one_attached :suppler_quote
  has_one_attached :final_supplier_quote
  has_one_attached :calculation_sheet

  # enum status: {
  #     :active => 10,
  #     :expired => 20,
  #     :won => 30
  # }

  enum status: {
      :'Order Won' => 18,
      :'Quotation Sent' => 5,
      :'Follow Up on Quotation' => 6,
      :'Expected Order' => 7,
      :'Hold by Accounts' => 20,
      :'SO Draft: Pending Accounts Approval' => 8,
      :'SO Not Created-Customer PO Awaited' => 13,
      :'SO Not Created-Pending Customer PO Revision' => 14,
      :'Draft SO for Approval by Sales Manager' => 15,
      :'Inquiry No. Assigned' => 0,
      :'Lead by O/S' => 11,
      :'Acknowledgement Mail' => 2,
      :'Preparing Quotation' => 4,
      :'Cross Reference' => 3,
      :'Supplier RFQ Sent' => 12,
      :'SO Rejected by Sales Manager' => 17,
      :'Regret' => 10,
      :'Order Lost' => 9,
      :'Rejected by Accounts' => 19,
  }

  enum stage: {
      inquiry_number_assigned: 1,
      prepare_quotation: 5,
      quotation_sent: 6,
      sales_order_approved: 92
  }

  enum opportunity_type: {
      :amazon => 10,
      :rate_contract => 20,
      :financing => 30,
      :regular => 40,
      :service => 50,
      :repeat => 60,
      :route_through => 70,
      :tender => 80
  }

  enum opportunity_source: {
      :unsure => 5,
      :meeting => 10,
      :phone_call => 20,
      :email => 30,
      :quote_tender_prep => 40
  }

  enum quote_category: {
      :bmro => 10,
      :ong => 20
  }

  enum price_type: {
      :exw => 10,
      :fob => 20,
      :cif => 30,
      :cfr => 40,
      :dap => 50,
      :door_delivery => 60,
      :fca_mumbai => 70,
      :cip => 80,
      :dd => 90,
      :cip_mumbai_airport => 100
  }

  enum freight_option: {
      :included => 10,
      :extra => 20
  }, _prefix: true

  enum packing_and_forwarding_option: {
      :added => 10,
      :not_added => 20
  }

  def commercial_status
    :open
  end

  scope :with_includes, -> {includes(:created_by, :updated_by, :contact, :inside_sales_owner, :outside_sales_owner, :company, :account, :final_sales_quote => [:rows => [:inquiry_product_supplier]])}

  attr_accessor :force_has_sales_orders
  with_options if: :has_sales_orders? do |inquiry|
    inquiry.validates_with FilePresenceValidator, attachment: :customer_po_sheet
    inquiry.validates_with FilePresenceValidator, attachment: :final_supplier_quote
    inquiry.validates_with FilePresenceValidator, attachment: :calculation_sheet
  end

  def has_sales_orders?
    self.sales_orders.present? || self.force_has_sales_orders == true
    false # comment this to enable
  end

  def valid_for_new_sales_order?
    self.force_has_sales_orders = true
    self.valid?
  end

  validates_with FileValidator, attachment: :customer_po_sheet, file_size_in_megabytes: 2
  validates_with FileValidator, attachment: :copy_of_email, file_size_in_megabytes: 2
  validates_with FileValidator, attachment: :suppler_quote, file_size_in_megabytes: 2
  validates_with FileValidator, attachment: :final_supplier_quote, file_size_in_megabytes: 2
  validates_with FileValidator, attachment: :calculation_sheet, file_size_in_megabytes: 2

  validates_numericality_of :gross_profit_percentage, greater_than_equal_to: 0, less_than_or_equal_to: 100, allow_nil: true
  validates_presence_of :inquiry_currency
  validates_presence_of :company
  # validates_presence_of :contact
  # validates_presence_of :billing_address
  # validates_presence_of :shipping_address

  validate :every_product_is_only_added_once?

  def every_product_is_only_added_once?
    if self.inquiry_products.uniq {|ip| ip.product_id}.size != self.inquiry_products.size
      errors.add(:inquiry_products, 'every product can only be included once in a particular inquiry')
    end
  end

  def get_smart_queue
    # SELECT quotation.*, star.starvalue, company.cmp_name, company.is_strategic, count(distinct opportunity.refno) as cntOpportunity, company.cmp_alias, company_alias.aliasname, u.firstname as managerfirstname, u.lastname as managerlastname,u2.firstname as outsidefirstname, u2.lastname as outsidelastname FROM quotation
    # LEFT JOIN starred_enquiry as star ON quotation.increment_id=star.inquiryid and star.staruserid = 171
    # LEFT JOIN opportunity ON quotation.increment_id=opportunity.enquiryids
    # LEFT JOIN company ON quotation.customer_company=company.cmp_id
    # LEFT JOIN company_alias ON company_alias.id=company.cmp_alias
    # LEFT JOIN admin_user as u ON u.username=quotation.manager
    # LEFT JOIN admin_user as u2 ON u.username=quotation.outside
    # where
    # -- manager = ''
    # quotation.is_closed = 0 AND
    # quotation.bought not in (11, 9, 10)
    # GROUP BY quotation.increment_id
    # order by is_prioritized desc, quotation_followup_date asc, price_ht2 DESC


  end

  # has_many :rfqs
  # accepts_nested_attributes_for :rfqs
  # attr_accessor :rfq_subject, :rfq_comments
  # has_many :s_products, :through => :inquiry_product_suppliers, :source => :product
  # has_one :sales_approval, :through => :sales_quote
  # has_one :sales_order, :through => :sales_approval

  # validates_length_of :inquiry_products, minimum: 1
  # validate :all_products_have_suppliers
  # def all_products_have_suppliers
  #   if products.size != s_products.uniq.size && self.inquiry_product_suppliers.present?
  #     errors.add(:inquiry_product_suppliers, 'every product must have at least one supplier')
  #   end
  # end

  def syncable_identifiers
    [:project_uid, :opportunity_uid]
  end

  after_initialize :set_defaults, :if => :new_record?

  def set_defaults
    if self.company.present?
      self.outside_sales_owner ||= self.company.outside_sales_owner if not_legacy?
      self.sales_manager ||= self.company.sales_manager if not_legacy?
      self.status ||= :'Inquiry No. Assigned'
      self.opportunity_type ||= :regular
      self.opportunity_source ||= :unsure
      self.quote_category ||= :bmro
      self.price_type ||= :exw
      self.freight_option ||= :included
      self.packing_and_forwarding_option ||= :added
      self.expected_closing_date ||= (Time.now + 60.days) if self.not_legacy?
      self.freight_cost ||= 0
      self.contact ||= self.company.default_company_contact.contact if self.company.default_company_contact.present?
      self.payment_option ||= self.company.default_payment_option
      self.billing_address ||= self.company.default_billing_address
      self.shipping_address ||= self.company.default_shipping_address
      self.bill_from ||= Warehouse.default
      self.ship_from ||= Warehouse.default
      self.commercial_terms_and_conditions ||= [
          "1. Cost does not include any additional certification if required as per Indian regulations.",
          "2. Any errors in quotation including HSN codes, GST Tax rates must be notified before placing order.",
          "3. Order once placed cannot be changed.",
          "4. BulkMRO does not accept any financial penalties for late deliveries."
      ].join("\r\n") if not_legacy?
    end

    self.is_sez ||= false
    self.inquiry_currency ||= self.build_inquiry_currency
    # self.inquiry_number ||= Inquiry.maximum(:inquiry_number) + 1
  end

  def draft?
    !inquiry_products.any?
  end

  def inquiry_products_for(supplier)
    self.inquiry_products.joins(:inquiry_product_suppliers).where('inquiry_product_suppliers.supplier_id = ?', supplier.id)
  end

  def suppliers_selected?
    self.inquiry_product_suppliers.persisted.present?
  end

  # def rfqs_generated?
  #   self.rfqs.persisted.present?
  # end
  #
  # def rfqs_generated_on
  #   self.rfqs.minimum(:created_at)
  # end

  def last_sr_no
    self.inquiry_products.maximum(:sr_no) || 0
  end

  def to_s
    [
        ['#', self.inquiry_number].join,
        self.company.name
    ].join(' ')
  end

end