

class InquiryImportRow < ApplicationRecord
  belongs_to :import, class_name: "InquiryImport", foreign_key: :inquiry_import_id
  has_one :inquiry, through: :import
  belongs_to :inquiry_product, required: false
  accepts_nested_attributes_for :inquiry_product, allow_destroy: true

  attr_accessor :approved_alternative_id

  scope :failed, -> { where(inquiry_product_id: nil)  }
  scope :successful, -> { where.not(inquiry_product_id: nil)  }

  validates_presence_of :metadata
  validates_uniqueness_of :sku, scope: :import, allow_nil: true
  validates_associated :inquiry_product

  def successful?
    inquiry_product.present?
  end

  def failed?
    !successful?
  end

  def approved_alternatives(page=1)
    service = Services::Overseers::Finders::Products.new({})
    service.manage_failed_skus([metadata["mpn"], metadata["name"]].map{ |a| a.to_s.strip }.compact.join(" "), 4, page)
  end
end
