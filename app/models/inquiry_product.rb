class InquiryProduct < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :inquiry
  has_one :company, :through => :inquiry
  belongs_to :product
  accepts_nested_attributes_for :product
  belongs_to :import, class_name: 'InquiryImport', foreign_key: :inquiry_import_id, :required => false
  has_many :inquiry_product_suppliers, :inverse_of => :inquiry_product, dependent: :destroy
  has_many :sales_quote_rows, :through => :inquiry_product_suppliers
  has_many :sales_quotes, :through => :inquiry
  has_one :final_sales_quote, :through => :inquiry, class_name: 'SalesQuote'
  has_one :final_sales_quote_row, -> (record) { where(:inquiry_product_id => record.id) }, :through => :final_sales_quote, class_name: 'SalesQuoteRow'
  has_one :approved_final_sales_order, :through => :inquiry, class_name: 'SalesOrder'
  has_many :suppliers, :through => :inquiry_product_suppliers, dependent: :destroy
  accepts_nested_attributes_for :inquiry_product_suppliers, allow_destroy: true
  has_one :inquiry_import_row, :dependent => :nullify, inverse_of: :inquiry_product

  scope :with_suppliers, -> { left_outer_joins(:inquiry_product_suppliers).where.not(:inquiry_product_suppliers => { id: nil }) }

  delegate :approved?, to: :product

  #attr_accessor :product_catalog_name

  validates_presence_of :quantity, :sr_no
  validates_uniqueness_of :product_id, scope: :inquiry_id
   validates_uniqueness_of :sr_no, scope: :inquiry_id
  # validates_numericality_of :quantity, :greater_than => 0
  after_initialize :set_defaults, :if => :new_record?

  def set_defaults
    self.quantity ||= 1
  end

  def best_tax_code
    self.product.tax_code.code if self.product.tax_code.present?
  end

  def to_bp_catalog_s
    [bp_catalog_sku, bp_catalog_name ? bp_catalog_name : self.product.name].compact.join(' - ')
  end
end
