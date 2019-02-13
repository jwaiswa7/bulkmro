class Product < ApplicationRecord
  COMMENTS_CLASS = 'ProductComment'
  REJECTIONS_CLASS = 'ProductRejection'
  APPROVALS_CLASS = 'ProductApproval'

  include ActiveModel::Validations
  include Mixins::CanBeStamped
  include Mixins::CanBeApproved
  include Mixins::CanBeRejected
  include Mixins::HasApproveableStatus
  include Mixins::HasComments
  include Mixins::CanBeSynced
  include Mixins::CanHaveTaxes
  include Mixins::CanBeActivated
  include Mixins::HasImages

  update_index('products#product') { self if self.approved? }
  pg_search_scope :locate, against: [:sku, :name], associated_against: { brand: [:name] }, using: { tsearch: { prefix: true } }

  belongs_to :brand, required: false
  belongs_to :category
  belongs_to :inquiry_import_row, required: false
  belongs_to :measurement_unit, required: false
  has_one :import, through: :inquiry_import_row, class_name: 'InquiryImport'
  has_one :inquiry, through: :import
  has_many :product_suppliers, dependent: :destroy
  has_many :inquiry_products, dependent: :destroy
  has_many :inquiry_product_suppliers, through: :inquiry_products
  has_many :suppliers, through: :inquiry_product_suppliers, class_name: 'Company', source: :supplier
  has_many :customer_order_rows
  has_many :customer_products
  has_one :kit
  has_many :cart_items
  has_many :stocks, class_name: 'WarehouseProductStock', inverse_of: :product, dependent: :destroy

  attr_accessor :applicable_tax_percentage

  enum product_type: { item: 10, service: 20 }

  scope :with_includes, -> { includes(:brand, :approval, :category, :tax_code) }
  scope :with_manage_failed_skus, -> { includes(:brand, :tax_code, category: [:tax_code]) }
  scope :is_service, ->{ where(is_service: true)}

  validates_presence_of :name

  validates_presence_of :sku, if: :not_rejected?
  validates_uniqueness_of :sku, if: :not_rejected?
  # validates_with MultipleImageFileValidator, attachments: :images

  after_initialize :set_defaults, if: :new_record?
  validate :unique_name?

  def unique_name?
    if self.not_rejected? && Product.not_rejected.where(name: self.name, is_active: true).count > 1 && self.is_active
      errors.add(:name, ' must be unique')
    end
  end

  def service_product
    if self.is_service && !self.category.is_service
      errors.add(:category, ' should be a service category')
    end

    if self.is_service && !self.tax_code.is_service
      errors.add(:tax_code, 'Tax Code should be a service tax code')
    end
  end

  def set_defaults
    self.measurement_unit ||= MeasurementUnit.default
    self.is_service ||= false
    self.weight ||= 0.0
    self.sku ||= generate_sku
  end

  def generate_sku
    Services::Resources::Shared::UidGenerator.product_sku
  end

  def syncable_identifiers
    [:remote_uid]
  end

  def best_tax_code
    self.tax_code || self.category.try(:tax_code)
  end

  def best_tax_rate
    self.tax_rate || self.category.try(:tax_rate)
  end

  def to_s
    "#{sku || trashed_sku} - #{name}"
  end

  def lowest_inquiry_product_supplier
    self.inquiry_product_suppliers.order(unit_cost_price: :asc).first
  end

  def lowest_inquiry_product_suppliers(number: 1)
    self.inquiry_product_suppliers.includes(:supplier).order(:unit_cost_price).uniq(&:supplier).first(number)
  end

  def latest_inquiry_product_supplier
    self.inquiry_product_suppliers.latest_record
  end

  def lowest_unit_cost_price
    lowest_inquiry_product_supplier.unit_cost_price if lowest_inquiry_product_supplier.present?
  end

  def latest_unit_cost_price
    latest_inquiry_product_supplier.unit_cost_price if latest_inquiry_product_supplier.present?
  end

  def lowest_unit_cost_price_for(supplier, except = nil)
    self.inquiry_product_suppliers.except_object(except).where(supplier: supplier).order(unit_cost_price: :asc).first.try(:unit_cost_price) || 'N/A'
  end

  def latest_unit_cost_price_for(supplier, except = nil)
    self.inquiry_product_suppliers.except_object(except).where(supplier: supplier).latest_record.try(:unit_cost_price) || 'N/A'
  end

  def bp_catalog_for_customer(company)
    self.inquiry_products.joins(:inquiry).where('inquiries.company_id = ?', company.id).order(updated_at: :desc).pluck(:bp_catalog_name, :bp_catalog_sku).compact.first
  end

  def bp_catalog_for_supplier(supplier)
    self.inquiry_product_suppliers.where('supplier_id = ?', supplier.id).order(updated_at: :desc).pluck(:bp_catalog_name, :bp_catalog_sku).compact.first if supplier.present?
  end

  def is_kit
    self.kit.present?
  end

  def is_kit_product
    self.kit_product_row.present?
  end

  def brand_name
    self.brand.name
  end

  def self.get_product_name(product_id)
    self.find(product_id).try(:name)
  end

  def with_images_to_s
    ["#{self.to_s}", has_images? ? " - Has #{self.images.count} Image(s)" : ''].join
  end

  def has_images?
    self.images.attached?
  end

  def get_customer_company_product(company_id)
    self.customer_products.where(company_id: company_id).first
  end
end
