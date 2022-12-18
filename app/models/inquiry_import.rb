# frozen_string_literal: true

class InquiryImport < ApplicationRecord
  HEADERS = %w[sr_no name brand mpn sku quantity tax_code tax_rate is_service category_id].freeze
  TEMPLATE_HEADERS = %w[sr_no name brand mpn sku quantity tax_code tax_rate is_service category_id].freeze
  RFQ_TEMPLATE_HEADERS = %w[sequence product_name sku min_lead_time_days max_lead_time_days unit_buying_price unit_selling_price gst_percentage tax_code freight vendor_code vendor_name]

  include Mixins::CanBeStamped
  include Mixins::IsAnImport

  belongs_to :inquiry
  has_many :inquiry_products, dependent: :destroy
  accepts_nested_attributes_for :inquiry_products, allow_destroy: true
  has_one_attached :file
  has_many :rows, class_name: 'InquiryImportRow'
  has_many :products, through: :rows
  accepts_nested_attributes_for :rows, allow_destroy: true

  delegate :to_s, to: :inquiry

  validates_presence_of :import_text, if: :list?
  validates :import_text, format: { with: /BM\d*[,]?\s?\d*/ }, if: :list?

  def to_s
    'InquiryImport'
  end
end
