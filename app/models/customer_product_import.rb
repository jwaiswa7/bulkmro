class CustomerProductImport < ApplicationRecord
  HEADERS = %w(sku price name material_code brand hsn tax_percentage moq uom url).freeze
  TEMPLATE_HEADERS = %w(sku price name material_code brand hsn tax_percentage moq uom url).freeze

  include Mixins::CanBeStamped
  include Mixins::IsAnImport

  belongs_to :company
  has_many :rows, class_name: "CustomerProductImportRow"
end
