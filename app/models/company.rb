class Company < ApplicationRecord
  include ActiveModel::Validations
  include Mixins::CanBeStamped
  include Mixins::CanBeSynced
  include Mixins::CanBeActivated
  # include Mixins::HasUniqueName
  include Mixins::HasManagers
  include Mixins::HasPaymentCollections

  update_index('companies#company') {self}
  pg_search_scope :locate, against: [:name], associated_against: {}, using: {tsearch: {prefix: true}}

  attr_accessor :account_name, :acc_type
  belongs_to :account
  belongs_to :default_company_contact, -> (record) {where(company_id: record.id)}, class_name: 'CompanyContact', foreign_key: :default_company_contact_id, required: false
  has_one :default_contact, through: :default_company_contact, source: :contact
  belongs_to :default_payment_option, class_name: 'PaymentOption', foreign_key: :default_payment_option_id, required: false
  belongs_to :default_billing_address, -> (record) {where(company_id: record.id)}, class_name: 'Address', foreign_key: :default_billing_address_id, required: false
  belongs_to :default_shipping_address, -> (record) {where(company_id: record.id)}, class_name: 'Address', foreign_key: :default_shipping_address_id, required: false
  belongs_to :logistics_owner, -> (record) {where(role: 'logistics')}, class_name: 'Overseer', foreign_key: 'logistics_owner_id', required: false
  belongs_to :industry, required: false
  has_many :banks, class_name: 'CompanyBank', inverse_of: :company
  has_many :company_contacts, dependent: :destroy
  has_many :contacts, through: :company_contacts
  accepts_nested_attributes_for :company_contacts
  has_many :product_suppliers, foreign_key: :supplier_id
  has_many :products, through: :product_suppliers
  accepts_nested_attributes_for :product_suppliers
  has_many :category_suppliers, foreign_key: :supplier_id
  has_many :categories, through: :category_suppliers
  accepts_nested_attributes_for :category_suppliers
  has_many :brand_suppliers, foreign_key: :supplier_id
  has_many :brands, through: :brand_suppliers
  has_many :brand_products, through: :brands, class_name: 'Product', source: :products
  accepts_nested_attributes_for :brand_suppliers
  has_many :inquiries
  has_many :inquiry_product_suppliers, through: :inquiries
  has_many :inquiry_products, through: :inquiries
  has_many :products, through: :inquiry_products
  has_many :supplier_products, foreign_key: :supplier_id
  has_many :sales_quotes, through: :inquiries, source: :sales_quotes
  has_many :final_sales_quotes, through: :inquiries, source: :final_sales_quote
  has_many :final_sales_orders, through: :inquiries, source: :final_sales_orders
  has_many :sales_orders, through: :inquiries
  has_many :invoices, through: :inquiries
  has_many :addresses, dependent: :destroy
  has_many :customer_products, dependent: :destroy
  has_many :company_products, through: :customer_products
  has_many :customer_orders
  has_many :product_imports, class_name: 'CustomerProductImport', inverse_of: :company
  has_many :company_banks
  has_many :banks, through: :company_banks
  has_many :tags
  has_many :purchase_orders
  has_many :supplied_products, through: :purchase_orders, source: :products
  has_many :supplied_brands, through: :supplied_products, source: :brand
  has_many :supplier_rfqs, foreign_key: :supplier_id


  has_many :sales_receipts
  has_many :payment_collections
  has_many :email_messages, dependent: :destroy

  has_one_attached :tan_proof
  has_one_attached :pan_proof
  has_one_attached :cen_proof
  has_one_attached :logo
  belongs_to :company_creation_request, optional: true

  scope :with_invoices, -> {includes(:invoices).where.not(sales_invoices: { id: nil })}


  enum company_type: {
      proprietorship: 10,
      private_limited: 20,
      contractor: 30,
      trust: 40,
      dealer_company: 50,
      distributor: 60,
      trader: 70,
      manufacturing_company: 80,
      wholesaler_stockist: 90,
      service_provider: 100,
      employee: 110
  }, _prefix: true

  enum priority: {
      non_strategic: 10,
      strategic: 20
  }, _prefix: true

  enum nature_of_business: {
      trading: 10,
      manufacturer: 20,
      dealer: 30
  }, _prefix: true

  delegate :mobile, :email, :telephone, to: :default_contact, allow_nil: true
  delegate :account_type, :is_customer?, :is_supplier?, to: :account
  alias_attribute :gst, :tax_identifier

  scope :with_includes, -> {includes(:addresses, :inquiries, :contacts, :invoices, :final_sales_orders, :final_sales_quotes)}
  scope :acts_as_supplier, -> {left_outer_joins(:account).where('accounts.account_type = ?', Account.account_types[:is_supplier]).order(name: :asc)}
  scope :acts_as_customer, -> {left_outer_joins(:account).where('accounts.account_type = ?', Account.account_types[:is_customer]).order(name: :asc)}
  scope :is_customer_active, -> { Company.acts_as_customer.where(is_active: true)}
  validates_presence_of :name
  validates :credit_limit, numericality: {greater_than_or_equal_to: 0}, allow_nil: true
  validates_presence_of :pan
  validates_uniqueness_of :remote_uid, on: :update, allow_nil: true
  validate :validate_pan?

  validates_with FileValidator, attachment: :tan_proof
  validates_with FileValidator, attachment: :pan_proof
  validates_with FileValidator, attachment: :cen_proof
  validates_with ImageFileValidator, attachment: :logo

  validate :name_is_conditionally_unique?

  def name_is_conditionally_unique?
    if Company.joins(:account).where(name: self.name).where.not(id: self.id).where('accounts.account_type = ?', Account.account_types[self.account.account_type]).exists?
      errors.add :name, 'has to be unique'
    end
  end

  after_initialize :set_defaults, if: :new_record?

  def set_defaults
    self.company_type ||= :private_limited
    self.priority ||= :non_strategic
    self.is_msme ||= false
    self.is_unregistered_dealer ||= false
    self.default_company_contact ||= set_default_company_contact
    self.default_billing_address ||= set_default_company_billing_address
    self.default_shipping_address ||= set_default_company_shipping_address
    self.logistics_owner ||= default_logistics_owner
  end

  def syncable_identifiers
    [:remote_uid]
  end

  def set_default_company_contact
    self.company_contacts.first
  end

  def set_default_company_billing_address
    self.addresses.first if !self.addresses.blank?
  end

  def set_default_company_shipping_address
    self.addresses.first if !self.addresses.blank?
  end

  def self.default_supplier
    find_by_name('Local')
  end

  def billing_address
    self.update_attributes(default_billing_address: self.set_default_company_billing_address) if self.default_billing_address.blank?
    self.default_billing_address
  end

  def shipping_address
    self.update_attributes(default_shipping_address: self.set_default_company_shipping_address) if self.default_shipping_address.blank?
    self.default_shipping_address
  end

  def default_logistics_owner
    Overseer.find(213)
  end

  def to_contextual_s(product)
    s = [self.to_s]

    if product.p_suppliers.include?(self)
      s.append('(Supplies product directly)')
    elsif product.c_suppliers.include?(self)
      s.append('(Supplies category)')
    else
      s.append('(Supplies brand)')
    end

    s.join(' ')
  end

  def generate_catalog(overseer)
    inquiry_products = Inquiry.includes(:inquiry_products, :products).where(company: self.id).map {|i| i.inquiry_products}.flatten
    inquiry_products.each do |inquiry_product|
      if inquiry_product.product.synced?
        CustomerProduct.where(company_id: inquiry_product.inquiry.company_id, product_id: inquiry_product.product_id, customer_price: (inquiry_product.product.latest_unit_cost_price || 0)).first_or_create! do |customer_product|
          customer_product.category_id = inquiry_product.product.category_id
          customer_product.brand_id = inquiry_product.product.brand_id
          customer_product.name = (inquiry_product.bp_catalog_name == '' ? nil : inquiry_product.bp_catalog_name) || inquiry_product.product.name
          customer_product.sku = (inquiry_product.bp_catalog_sku == '' ? nil : inquiry_product.bp_catalog_sku) || inquiry_product.product.sku
          customer_product.tax_code = inquiry_product.product.best_tax_code
          customer_product.tax_rate = inquiry_product.best_tax_rate
          customer_product.measurement_unit = inquiry_product.product.measurement_unit
          customer_product.moq = 1
          customer_product.created_by = overseer
        end
      end
    end
  end

  def customer_product_for(product)
    customer_products.joins(:product).where('products.id = ?', product.id).first
  end

  def self.legacy
    self.find_by_name('Legacy Company')
  end

  def validate_pan
    if self.pan.present?
      self.pan.match?(/^[A-Z]{5}\d{4}[A-Z]{1}$/)
    else
      false
    end
  end

  def validate_pan?
    if self.pan.blank? || self.pan.length != 10
      errors.add(:company, 'PAN is not valid')
    end
  end

  def company_rating
    rating_for self, 'supplier_responsiveness', star: Random.rand(1..5)
  end

  def to_s_with_type
    type = self.account.is_supplier? ? 'S' : 'C'
    [self.to_s, ' (', type, ')'].join('')
  end

  def inquiry_size
    self.inquiries.where.not('inquiries.status = ? OR inquiries.status = ?', 10, 9).size
  end

  def cancel
    self.inquiries.map {|i| i.sales_invoices.map {|s| s.status.where(status: 'Cancelled')}.size}
  end

  def invoice_margin
    self.invoices.map {|s| s.inquiry.final_sales_quote.calculated_total_margin_percentage.to_f if s.inquiry.final_sales_quote.present?}.flatten.compact
  end

  def order_margin
    self.inquiries.map {|i| i.final_sales_orders.map {|s| s.calculated_total_margin_percentage} if i.final_sales_orders.present?}.flatten.compact
  end

  def account_manager_contact
    self.contacts.where(role: 'account_manager').first
  end

  def total_open_inquiries
    Rails.cache.fetch([self, 'total_open_inquiries']) do
      Inquiry.left_outer_joins(:sales_quotes).where('inquiries.company_id = ? AND inquiries.status NOT IN (?,?)', self.id, 9, 10).where(sales_quotes: {id: nil}).size
    end
  end

  def total_open_quotes
    Rails.cache.fetch([self, 'total_open_quotes']) do
      open_quotes = 0
      total_value = 0
      self.inquiries.each do |inquiry|
        if inquiry.sales_quotes.present?
          sq = inquiry.sales_quotes.last
          if sq.sales_orders.blank?
            open_quotes += 1
            total_value += sq.converted_total_with_tax
          end
        end
      end
      {
          open_quotes: open_quotes,
          total_value: total_value
      }
    end
  end

  def total_sales_order
    Rails.cache.fetch([self, 'total_sales_order']) do
      confirmed_orders = 0
      confirmed_orders_total_value = 0
      confirmed_invoices = 0
      confirmed_invoices_total_value = 0
      self.inquiries.each do |inquiry|
        inquiry.sales_orders.remote_approved.each do |so|
          confirmed_orders += 1
          confirmed_orders_total_value += so.converted_total_with_tax
          so.invoices.each do | si |
            confirmed_invoices += 1
            confirmed_invoices_total_value += si.metadata['base_grand_total'].to_f
          end
        end
      end

      {
          confirmed_orders: confirmed_orders,
          confirmed_orders_total_value: confirmed_orders_total_value,
          confirmed_invoices: confirmed_invoices,
          confirmed_invoices_total_value: confirmed_invoices_total_value
      }
    end
  end
end
