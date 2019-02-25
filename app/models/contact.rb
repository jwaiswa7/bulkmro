class Contact < ApplicationRecord
  include Mixins::IsAPerson
  include Mixins::CanBeStamped
  include Mixins::CanBeSynced
  include Mixins::HasMobileAndTelephone
  include Mixins::CanBeActivated

  update_index('contacts#contact') { self }
  pg_search_scope :locate, against: [:first_name, :last_name, :email], associated_against: { account: [:name] }, using: { tsearch: { prefix: true } }

  # Include default devise modules. Others available are:
  # :confirmable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable

  belongs_to :account
  has_many :inquiries
  has_many :company_contacts
  has_many :companies, through: :company_contacts
  accepts_nested_attributes_for :company_contacts
  has_one :company_contact
  has_one :company, through: :company_contact
  has_one :cart
  has_many :customer_orders
  has_many :customer_products, through: :companies
  has_many :customer_order_comments

  enum role: { customer: 10, account_manager: 20 }
  enum status: { active: 10, inactive: 20 }
  enum contact_group: {
      general: 10,
      company_top_manager: 20,
      retailer: 30,
      ador: 40,
      vmi_group: 50,
      c_form_customer_group: 60,
      manager: 70,
  }

  validates_presence_of :telephone, if: -> {!self.mobile.present? && not_legacy?}
  validates_presence_of :mobile, if: -> {!self.telephone.present? && not_legacy?}
  scope :with_includes, -> {includes(:account,:inquiries)}
  after_initialize :set_defaults, :if => :new_record?
  attr_accessor :current_password

  def set_defaults
    self.role ||= :customer
    self.status ||= :active
    self.contact_group ||= :general

    password = Devise.friendly_token[0, 20]
    self.password ||= password
    self.password_confirmation ||= password

    if self.company.present?
      self.account ||= self.company.account
    end
  end

  def self.legacy
    find_by_email('legacy@bulkmro.com')
  end

  def current_cart
    self.cart
  end

  def generate_products
    overseer = Overseer.default
    customer_companies = self.companies.pluck(:id)
    inquiry_products = Inquiry.includes(:inquiry_products, :products).where(company: customer_companies).map { |i| i.inquiry_products }.flatten
    inquiry_products.each do |inquiry_product|
      if inquiry_product.product.synced?
        CustomerProduct.where(company_id: inquiry_product.inquiry.company_id, product_id: inquiry_product.product_id).first_or_create! do |customer_product|
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
end
