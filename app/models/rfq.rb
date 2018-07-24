class Rfq < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :supplier, class_name: 'Company', foreign_key: :supplier_id
  belongs_to :inquiry

  has_many :inquiry_suppliers, -> (object) { where(:supplier => object.supplier) }, :through => :inquiry
  has_many :inquiry_products, :through => :inquiry_suppliers
  has_many :products, :through => :inquiry_products
  accepts_nested_attributes_for :inquiry_suppliers

  has_many :rfq_contacts
  has_many :contacts, :through => :rfq_contacts
  accepts_nested_attributes_for :rfq_contacts

  validates_length_of :products, minimum: 1
  validates_length_of :contacts, minimum: 1
  validates_presence_of :subject
end