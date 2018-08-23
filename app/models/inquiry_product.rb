class InquiryProduct < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :inquiry
  belongs_to :product
  belongs_to :import, class_name: 'InquiryImport', foreign_key: :inquiry_import_id, :required => false
  has_many :inquiry_suppliers, :inverse_of => :inquiry_product
  has_many :suppliers, :through => :inquiry_suppliers
  accepts_nested_attributes_for :inquiry_suppliers

  validates_presence_of :quantity
  validates_uniqueness_of :product, scope: :inquiry
  validates_numericality_of :quantity, :greater_than => 0

  after_initialize :set_defaults, :if => :new_record?
  def set_defaults
    self.quantity ||= 1
  end
end
