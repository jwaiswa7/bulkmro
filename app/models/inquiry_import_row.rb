class InquiryImportRow < ApplicationRecord
  belongs_to :import, class_name: 'InquiryImport', foreign_key: :inquiry_import_id
  has_one :inquiry, :through => :import
  belongs_to :inquiry_product, required: false
  accepts_nested_attributes_for :inquiry_product, allow_destroy: true

  attr_accessor :approved_alternative_id

  scope :failed, -> { where(:inquiry_product_id => nil)  }
  scope :successful, -> { where.not(:inquiry_product_id => nil)  }

  validates_presence_of :sku, :metadata
  validates_uniqueness_of :sku, scope: :import
  validates_associated :inquiry_product

  def successful?
    inquiry_product.present?
  end

  def failed?
    !successful?
  end

  def approved_alternatives(page=1)
    Product.approved.not_rejected.locate(metadata['name']).except_objects(inquiry.products).page(page).per(4)
  end
end
