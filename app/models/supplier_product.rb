class SupplierProduct < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::HasSupplier
  include Mixins::HasImages
  include Mixins::CanBeWatermarked

  update_index('supplier_products#supplier_product') {self}
  pg_search_scope :locate, against: [:sku, :name], associated_against: {brand: [:name]}, using: {tsearch: {prefix: true}}

  belongs_to :brand, required: false
  belongs_to :category, required: false
  belongs_to :supplier, class_name: 'Company', foreign_key: :supplier_id
  belongs_to :product
  belongs_to :tax_code, required: false
  belongs_to :tax_rate, required: false
  belongs_to :measurement_unit, required: false

  validates_presence_of :name

  validates_presence_of :sku
  validates_presence_of :supplier_price

  validates_uniqueness_of :product_id, scope: :supplier_id
  validates_presence_of :moq

  scope :with_includes, -> {includes(:brand, :category)}
  scope :with_eager_loaded_images, -> { eager_load(images_attachments: :blob) }

  after_initialize :set_defaults, if: :new_record?

  def set_defaults
    self.moq ||= 1
  end

  # after_save :update_index
  #
  # def update_index
  #   CustomerProductsIndex::CustomerProduct.import([self.id])
  # end

  def best_brand
    self.brand || self.product.brand
  end

  def best_tax_code
    self.tax_code || self.product.best_tax_code
  end

  def best_tax_rate
    self.tax_rate || self.product.best_tax_rate
  end

  def best_measurement_unit
    self.measurement_unit || self.product.measurement_unit
  end

  def best_category
    self.category || self.product.category
  end

  def bp_catalog_name
    if product.inquiry_products.present?
      if self.product.inquiry_products.last.bp_catalog_name.present?
        self.product.inquiry_products.last.bp_catalog_name
      elsif self.product.present?
        self.product.name
      else
        self.name
      end
    else
      self.name
    end
  end

  def bp_catalog_sku
    if product.inquiry_products.present?
      if self.product.inquiry_products.last.bp_catalog_sku.present?
        self.product.inquiry_products.last.bp_catalog_sku
      elsif self.product.present?
        self.product.sku
      else
        self.sku
      end
    else
      self.sku
    end
  end

  def best_images
    if self.images.present?
      self.images
    elsif self.product.images.present?
      self.product.images
    else
      nil
    end
  end

  def best_image
    if best_images.present?
      if best_images.first.present?
        best_images.first
      else
        nil
      end
    end
  end

  def has_images?
    self.best_images.attached?
  end
end
