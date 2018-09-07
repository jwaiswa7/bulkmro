class Company < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::HasUniqueName

  pg_search_scope :locate, :against => [:name], :associated_against => { }, :using => { :tsearch => {:prefix => true} }

  belongs_to :account
  belongs_to :default_payment_option, class_name: 'PaymentOption', foreign_key: :default_payment_option_id
  belongs_to :industry

  has_many :banks, class_name: 'CompanyBank', inverse_of: :company

  has_many :company_contacts
  has_many :contacts, :through => :company_contacts
  accepts_nested_attributes_for :company_contacts

  # Supplier through products
  has_many :product_suppliers, foreign_key: :supplier_id
  has_many :products, :through => :product_suppliers
  accepts_nested_attributes_for :product_suppliers

  # Supplier through categories
  has_many :category_suppliers, foreign_key: :supplier_id
  has_many :categories, :through => :category_suppliers
  accepts_nested_attributes_for :category_suppliers

  # Supplier through brands
  has_many :brand_suppliers, foreign_key: :supplier_id
  has_many :brands, :through => :brand_suppliers
  has_many :brand_products, :through => :brands, :class_name => 'Product', :source => :products
  accepts_nested_attributes_for :brand_suppliers

  has_many :inquiries
  has_many :inquiry_product_suppliers, :through => :inquiries
  has_many :addresses

  # Attachments
  has_one_attached :tan_doc
  has_one_attached :pan_doc
  has_one_attached :excise_doc

  # todo implement
  scope :acts_as_supplier, -> { }

  alias_attribute :gst, :tax_identifier
  validates_presence_of :tax_identifier  
  validates_uniqueness_of :tax_identifier

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