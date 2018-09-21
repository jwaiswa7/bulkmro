class Company < ApplicationRecord
  include ActiveModel::Validations
  include Mixins::CanBeStamped
  include Mixins::HasUniqueName
  include Mixins::HasManagers

  pg_search_scope :locate, :against => [:name], :associated_against => { }, :using => { :tsearch => {:prefix => true} }

  belongs_to :account
  belongs_to :default_company_contact, -> (record) { where(company_id: record.id) }, class_name: 'CompanyContact', foreign_key: :default_company_contact_id, required: false
  has_one :default_contact, :through => :default_company_contact, source: :contact
  belongs_to :default_payment_option, class_name: 'PaymentOption', foreign_key: :default_payment_option_id, required: false
  belongs_to :default_billing_address, -> (record) { where(company_id: record.id) }, class_name: 'Address', foreign_key: :default_billing_address_id, required: false
  belongs_to :default_shipping_address, -> (record) { where(company_id: record.id) }, class_name: 'Address', foreign_key: :default_shipping_address_id, required: false
  belongs_to :industry, required: false

  has_many :banks, class_name: 'CompanyBank', inverse_of: :company

  has_many :company_contacts
  has_many :contacts, :through => :company_contacts
  accepts_nested_attributes_for :company_contacts

  has_many :product_suppliers, foreign_key: :supplier_id
  has_many :products, :through => :product_suppliers
  accepts_nested_attributes_for :product_suppliers

  has_many :category_suppliers, foreign_key: :supplier_id
  has_many :categories, :through => :category_suppliers
  accepts_nested_attributes_for :category_suppliers

  has_many :brand_suppliers, foreign_key: :supplier_id
  has_many :brands, :through => :brand_suppliers
  has_many :brand_products, :through => :brands, :class_name => 'Product', :source => :products
  accepts_nested_attributes_for :brand_suppliers

  has_many :inquiries
  has_many :inquiry_product_suppliers, :through => :inquiries
  has_many :addresses

  has_one_attached :tan_proof
  has_one_attached :pan_proof
  has_one_attached :cen_proof

  enum company_type: {
      :proprietorship => 10,
      :private_limited => 20,
      :contractor => 30,
      :trust => 40,
      :dealer_company => 50,
      :distributor => 60,
      :trader => 70,
      :manufacturer_company => 80,
      :wholesaler_stockist => 90,
      :serviceprovider => 100,
      :employee => 110
  }

  enum priority: {
      standard: 10,
      strategic: 20
  }

  enum nature_of_business: {
      trading: 10,
      manufacturer: 20,
      dealer: 30
  }

  alias_attribute :gst, :tax_identifier

  # todo implement
  scope :acts_as_supplier, -> { }

  # validates_presence_of :gst
  # validates_uniqueness_of :gst
  validates :credit_limit, numericality: { greater_than: 0 }, allow_nil: true
  validates_with FileValidator, attachment: :tan_proof
  validates_with FileValidator, attachment: :pan_proof
  validates_with FileValidator, attachment: :cen_proof

  delegate :mobile, :email, :telephone, to: :default_contact, allow_nil: true

  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    self.company_type ||= :private_limited
    self.priority ||= :standard
    self.is_msme ||= false
    self.is_unregistered_dealer ||= false
    self.default_company_contact ||= set_default_company_contact
  end

  def set_default_company_contact
    self.company_contacts.first
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
end