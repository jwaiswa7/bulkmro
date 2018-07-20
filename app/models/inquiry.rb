class Inquiry < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :contact
  belongs_to :company

  belongs_to :billing_address, class_name: 'Address', foreign_key: 'billing_address_id'
  belongs_to :shipping_address, class_name: 'Address', foreign_key: 'shipping_address_id'

  has_many :inquiry_products, :inverse_of => :inquiry
  has_many :products, :through => :inquiry_products
  has_many :inquiry_suppliers, :through => :inquiry_products
  has_many :s_products, :through => :inquiry_suppliers, :source => :product
  accepts_nested_attributes_for :inquiry_products
  has_many :brands, :through => :products
  has_many :suppliers, :through => :inquiry_suppliers

  has_many :quotes
  has_many :rfqs

  validate :all_products_have_suppliers

  def all_products_have_suppliers
    if products.size != s_products.size && self.inquiry_suppliers.present?
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
end