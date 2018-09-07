class Inquiry < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::HasAddresses
  include Mixins::CanBeSynced

  pg_search_scope :locate, :against => [], :associated_against => { contact: [:first_name, :last_name], company: [:name] }, :using => { :tsearch => {:prefix => true} }

  belongs_to :contact
  belongs_to :company
  has_one :account, :through => :company
  has_many :inquiry_products, :inverse_of => :inquiry
  accepts_nested_attributes_for :inquiry_products, reject_if: lambda { |attributes| attributes['product_id'].blank? && attributes['id'].blank? }, allow_destroy: true
  has_many :products, :through => :inquiry_products
  has_many :approvals, :through => :products, :class_name => 'ProductApproval'
  has_many :inquiry_product_suppliers, :through => :inquiry_products
  has_many :brands, :through => :products
  has_many :suppliers, :through => :inquiry_product_suppliers
  has_many :imports, :class_name => 'InquiryImport', inverse_of: :inquiry
  has_many :sales_quotes
  has_many :sales_orders, :through => :sales_quotes
  attr_accessor :inside_sales_owner, :outside_sales_manager, :manager, :quote_category, :potential_amount, :opportunity_source, :opportunity_type, :price_basis, :payment_terms, :freight, :packing_and_forwarding, :commertial_terms_and_conditions
  # has_many :rfqs
  # accepts_nested_attributes_for :rfqs
  # attr_accessor :rfq_subject, :rfq_comments
  # has_many :s_products, :through => :inquiry_product_suppliers, :source => :product
  # has_one :sales_approval, :through => :sales_quote
  # has_one :sales_order, :through => :sales_approval

  # validates_length_of :inquiry_products, minimum: 1
  # validate :all_products_have_suppliers

  def self.syncable_identifiers
    [:project_uid, :quotation_uid]
  end

  def draft?
    !inquiry_products.any?
  end

  # def all_products_have_suppliers
  #   if products.size != s_products.uniq.size && self.inquiry_product_suppliers.present?
  #     errors.add(:inquiry_product_suppliers, 'every product must have at least one supplier')
  #   end
  # end

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
end