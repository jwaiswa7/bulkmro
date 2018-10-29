class PurchaseOrder < ApplicationRecord
  include Mixins::HasConvertedCalculations
  update_index('purchase_orders#purchase_order') {self}

  belongs_to :inquiry
  has_one :inquiry_currency, :through => :inquiry
  has_one :currency, :through => :inquiry_currency
  has_one :conversion_rate, :through => :inquiry_currency
  has_many :rows, class_name: 'PurchaseOrderRow', inverse_of: :purchase_order
  has_one_attached :document

  validates_with FileValidator, attachment: :document, file_size_in_megabytes: 2

  scope :with_includes, -> {includes(:inquiry)}

  def filename(include_extension: false)
    [
        ['po', po_number].join('_'),
        ('pdf' if include_extension)
    ].compact.join('.')
  end

  def get_supplier(product_id)
    product_supplier = self.inquiry.final_sales_quote.rows.select { | supplier_row |  supplier_row.product.id == product_id || supplier_row.product.legacy_id  == product_id}.first
    product_supplier.supplier if product_supplier.present?
  end
end
