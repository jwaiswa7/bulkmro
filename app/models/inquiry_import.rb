class InquiryImport < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :inquiry
  has_many :inquiry_products, dependent: :destroy
  accepts_nested_attributes_for :inquiry_products, allow_destroy: true
  has_one_attached :file
  has_many :rows, :class_name => 'InquiryImportRow'
  has_many :products, :through => :rows
  accepts_nested_attributes_for :rows, allow_destroy: true

  validates_presence_of :import_type
  validates_presence_of :import_text, :if => :list?
  validates :import_text, format: { with: /BM\d*[,]?\s?\d*/ }, :if => :list?

  validates :file, file_content_type: { allow: ['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'] }, if: -> { file.attached? }
  validate :has_file_attachment, :if => :excel?

  def has_file_attachment
    if !file.attached?
      errors.add(:base, 'File is required')
    end
  end

  enum import_type: { excel: 10, list: 20 }

  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    self.import_type ||= :excel
  end
end
