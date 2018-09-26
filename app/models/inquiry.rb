class Inquiry < ApplicationRecord
  COMMENTS_CLASS = 'InquiryComment'

  include Mixins::CanBeStamped
  include Mixins::HasAddresses
  include Mixins::CanBeSynced
  include Mixins::HasManagers
  include Mixins::HasComments

  pg_search_scope :locate, :against => [], :associated_against => { company: [:name] }, :using => { :tsearch => {:prefix => true} }

  belongs_to :inquiry_currency
  has_one :currency, :through => :inquiry_currency
  belongs_to :contact, -> (record) { joins(:company_contacts).where('company_contacts.company_id = ?', record.company_id) }
  belongs_to :company
  has_one :industry, :through => :company
  belongs_to :billing_address, -> (record) { where(company_id: record.company.id) }, class_name: 'Address', foreign_key: :billing_address_id, required: false
  belongs_to :shipping_address, -> (record) { where(company_id: record.company.id) }, class_name: 'Address', foreign_key: :shipping_address_id, required: false
  has_one :account, :through => :company
  has_many :inquiry_products, -> { order(sr_no: :asc) }, :inverse_of => :inquiry
  accepts_nested_attributes_for :inquiry_products, reject_if: lambda { |attributes| attributes['product_id'].blank? && attributes['id'].blank? }, allow_destroy: true
  has_many :products, :through => :inquiry_products
  has_many :approvals, :through => :products, :class_name => 'ProductApproval'
  has_many :inquiry_product_suppliers, :through => :inquiry_products
  has_many :brands, :through => :products
  has_many :suppliers, :through => :inquiry_product_suppliers
  has_many :imports, :class_name => 'InquiryImport', inverse_of: :inquiry
  has_many :sales_quotes
  has_one :final_sales_quote, -> { where.not(:sent_at => nil).latest }, class_name: 'SalesQuote'
  has_many :sales_orders, :through => :sales_quotes
  belongs_to :payment_option
  has_many :email_messages

  accepts_nested_attributes_for :comments

  enum status: {
      :active => 10,
      :expired => 20,
      :won => 30
  }

  enum stage: {
      inquiry_number_assigned: 1,
      prepare_quotation: 5,
      quotation_sent: 6,
      sales_order_approved: 92
  }

  validates_numericality_of :gross_profit_percentage, greater_than_equal_to: 0, less_than: 100, allow_nil: true

  def commercial_status

  end

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
    :cip => 80
  }

  enum freight_option: {
    :included => 10,
    :extra => 20
  }

  enum packing_and_forwarding_option: {
    :added => 10,
    :not_added => 20
  }

  validates_presence_of :inquiry_currency
  validates_presence_of :contact
  validates_presence_of :company
  validates_presence_of :billing_address
  validates_presence_of :shipping_address

  validate :every_product_is_only_added_once?

  def every_product_is_only_added_once?
    if self.inquiry_products.uniq { |ip| ip.product_id }.size != self.inquiry_products.size
      errors.add(:inquiry_products, 'every product can only be included once in a particular inquiry')
    end
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
      self.outside_sales_owner ||= self.company.outside_sales_owner
      self.sales_manager ||= self.sales_manager
      self.status ||= :active
      self.opportunity_type ||= :regular
      self.opportunity_source ||= :meeting
      self.quote_category ||= :bmro
      self.price_type ||= :exw
      self.freight_option ||= :included
      self.packing_and_forwarding_option ||= :added
      self.expected_closing_date ||= (Time.now + 60.days)

      self.contact ||= self.company.default_company_contact.contact if self.company.default_company_contact.present?
      self.payment_option ||= self.company.default_payment_option
      self.billing_address ||= self.company.default_billing_address
      self.shipping_address ||= self.company.default_shipping_address
    end

    self.inquiry_currency ||= self.build_inquiry_currency
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

  def rfqs_generated?
    self.rfqs.persisted.present?
  end

  def rfqs_generated_on
    self.rfqs.minimum(:created_at)
  end

  def last_sr_no
    self.inquiry_products.maximum(:sr_no) || 0
  end

  def to_s
    self.company.name
  end
end