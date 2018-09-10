class Inquiry < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::HasAddresses
  include Mixins::HasManagers

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
  belongs_to :payment_option

  enum status: {
    # TODO add statuses
  }

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
    :phome_call => 20,
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

  # has_many :rfqs
  # accepts_nested_attributes_for :rfqs
  # attr_accessor :rfq_subject, :rfq_comments
  # has_many :s_products, :through => :inquiry_product_suppliers, :source => :product
  # has_one :sales_approval, :through => :sales_quote
  # has_one :sales_order, :through => :sales_approval

  # validates_length_of :inquiry_products, minimum: 1
  # validate :all_products_have_suppliers


  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    if self.company.present?
      self.outside_sales_owner ||= self.company.outside_sales_owner
      self.sales_manager ||= self.sales_manager
      self.opportunity_type ||= :regular
      self.opportunity_source ||= :meeting
      self.quote_category ||= :bmro
      self.price_option ||= :exw
      self.freight_option ||= :included
      self.packing_and_forwarding_option ||= :added
      self.expected_closing_date ||= (Time.now + 60.days)
    end
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