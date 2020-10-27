# frozen_string_literal: true

class CustomerProductImport < ApplicationRecord
  HEADERS = %w[sku price name technical_description material_code customer_material_code lead_time brand hsn tax_percentage moq uom customer_uom url].freeze
  TEMPLATE_HEADERS = %w[sku price name technical_description material_code customer_material_code lead_time brand hsn tax_percentage moq uom customer_uom url].freeze

  include Mixins::CanBeStamped
  include Mixins::IsAnImport

  belongs_to :company
  has_many :rows, class_name: 'CustomerProductImportRow'
end
