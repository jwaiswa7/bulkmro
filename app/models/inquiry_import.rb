# frozen_string_literal: true

class InquiryImport < ApplicationRecord
  HEADERS = %w[sr_no name brand mpn sku quantity tax_code is_service category_id].freeze
  TEMPLATE_HEADERS = %w[sr_no name brand mpn sku quantity tax_code is_service category_id].freeze

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
