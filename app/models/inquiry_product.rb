class InquiryProduct < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :inquiry
  belongs_to :product
  accepts_nested_attributes_for :product
  belongs_to :import, class_name: 'InquiryImport', foreign_key: :inquiry_import_id, :required => false
  has_many :inquiry_product_suppliers, :inverse_of => :inquiry_product
  has_many :sales_quote_rows, :through => :inquiry_product_suppliers
  has_many :suppliers, :through => :inquiry_product_suppliers, dependent: :destroy
  accepts_nested_attributes_for :inquiry_product_suppliers, allow_destroy: true
  has_one :inquiry_import_row, :dependent => :nullify, inverse_of: :inquiry_product

  scope :with_suppliers, -> { left_outer_joins(:inquiry_product_suppliers).where.not(:inquiry_product_suppliers => { id: nil }) }

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
