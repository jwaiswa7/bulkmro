class InquiryImportRow < ApplicationRecord
  belongs_to :import, class_name: 'InquiryImport', foreign_key: :inquiry_import_id
  belongs_to :inquiry_product, required: false
  accepts_nested_attributes_for :inquiry_product, allow_destroy: true

  scope :failed, -> { where(:inquiry_product => nil)  }
  scope :successful, -> { where.not(:inquiry_product => nil)  }

  validates_presence_of :sku, :metadata
  validates_uniqueness_of :sku, scope: :import

  def successful?
    inquiry_product.present?
  end

  def failed?
    !successful?
  end
end
