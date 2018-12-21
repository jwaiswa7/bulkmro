class CustomerProductImport < ApplicationRecord
  HEADERS = %w(sku price name material_code brand hsn tax_percentage moq uom url).freeze
  TEMPLATE_HEADERS = %w(sku price name material_code brand hsn tax_percentage moq uom url).freeze
  include Mixins::CanBeStamped
  has_one_attached :file
  belongs_to :company
  has_many :rows, :class_name => 'CustomerProductImportRow'
end