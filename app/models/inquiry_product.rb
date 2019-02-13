

class InquiryProduct < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :inquiry
  has_one :company, through: :inquiry
  belongs_to :product, validate: false
  accepts_nested_attributes_for :product
  belongs_to :import, class_name: "InquiryImport", foreign_key: :inquiry_import_id, required: false
  has_many :inquiry_product_suppliers, inverse_of: :inquiry_product, dependent: :destroy
  has_many :sales_quote_rows, through: :inquiry_product_suppliers
  has_one :final_sales_order, -> { approved }, through: :inquiry, source: :final_sales_orders
  has_many :suppliers, through: :inquiry_product_suppliers, dependent: :destroy
  accepts_nested_attributes_for :inquiry_product_suppliers, allow_destroy: true
  has_one :inquiry_import_row, dependent: :nullify, inverse_of: :inquiry_product

  scope :with_suppliers, -> { left_outer_joins(:inquiry_product_suppliers).where.not(inquiry_product_suppliers: { id: nil }) }

  delegate :approved?, :is_kit?, to: :product

  # attr_accessor :product_catalog_name

  validates_presence_of :quantity, :sr_no
  validates_uniqueness_of :product_id, scope: :inquiry_id
  # validates_uniqueness_of :sr_no, scope: :inquiry_id, if: :not_legacy?
  # validates_numericality_of :quantity, :greater_than => 0
  after_initialize :set_defaults, if: :new_record?

  after_create :increase_product_count
  before_destroy :decrease_product_count

  def increase_product_count
    self.product.update_attribute("total_quotes", self.product.total_quotes + 1) if self.product.present?
  end

  def decrease_product_count
    self.product.update_attribute("total_quotes", (self.product.total_quotes == 0 ? 0 : (self.product.total_quotes - 1))) if self.product.present?
  end

  def set_defaults
    self.quantity ||= 1
  end

  def best_tax_code
    self.product.tax_code.code if self.product.tax_code.present?
  end

  def best_tax_rate
    self.product.best_tax_rate if self.product.best_tax_rate.present?
  end

  def to_s
    [bp_catalog_sku.present? ? bp_catalog_sku : self.product.sku, bp_catalog_name.present? ? bp_catalog_name : self.product.name].reject(&:blank?).compact.join(" - ")
  end

  def to_bp_catalog_s
    [bp_catalog_sku, bp_catalog_name.present? ? bp_catalog_name : self.product.name].reject(&:blank?).compact.join(" - ")
  end
end
