class InquiryProduct < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :inquiry
  belongs_to :product
  accepts_nested_attributes_for :product
  belongs_to :import, class_name: 'InquiryImport', foreign_key: :inquiry_import_id, :required => false
  has_many :inquiry_suppliers, :inverse_of => :inquiry_product
  has_many :sales_products, :through => :inquiry_suppliers
  has_many :suppliers, :through => :inquiry_suppliers
  accepts_nested_attributes_for :inquiry_suppliers, allow_destroy: true
  has_one :import_row, :class_name => 'InquiryImportRow', :dependent => :nullify, inverse_of: :inquiry_product

  scope :with_suppliers, -> { left_outer_joins(:inquiry_suppliers).where.not(:inquiry_suppliers => { id: nil }) }

  delegate :approved?, to: :product

  # attr_accessor :alternate

  validates_presence_of :quantity
  validates_uniqueness_of :inquiry_id, scope: :product_id
  validates_numericality_of :quantity, :greater_than => 0

  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    self.quantity ||= 1
  end
end
