class Inquiry < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::HasAddresses

  belongs_to :contact
  belongs_to :company
  has_one :account, :through => :company
  has_many :inquiry_products, :inverse_of => :inquiry
  has_many :products, :through => :inquiry_products
  has_many :inquiry_suppliers, :through => :inquiry_products
  has_many :s_products, :through => :inquiry_suppliers, :source => :product
  accepts_nested_attributes_for :inquiry_products, reject_if: lambda { |attributes| attributes['product_id'].blank? && attributes['id'].blank? }
  has_many :brands, :through => :products
  has_many :suppliers, :through => :inquiry_suppliers

  has_many :rfqs
  accepts_nested_attributes_for :rfqs
  attr_accessor :rfq_subject, :rfq_comments

  has_one :sales_quote

  validates_length_of :inquiry_products, minimum: 1
  validate :all_products_have_suppliers

  def all_products_have_suppliers
    if products.size != s_products.uniq.size && self.inquiry_suppliers.present?
      errors.add(:inquiry_suppliers, 'every product must have at least one supplier')
    end
  end

  def inquiry_products_for(supplier)
    self.inquiry_products.joins(:inquiry_suppliers).where('inquiry_suppliers.supplier_id = ?', supplier.id)
  end

  def suppliers_selected?
    self.inquiry_suppliers.persisted.present?
  end

  def rfqs_generated?
    self.rfqs.persisted.present?
  end

  def rfqs_generated_on
    self.rfqs.minimum(:created_at)
  end
end