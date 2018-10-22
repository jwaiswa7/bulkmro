class PurchaseOrder < ApplicationRecord
  belongs_to :inquiry
  has_many :rows, class_name: 'PurchaseOrderRow', inverse_of: :purchase_order
  has_one_attached :document
  include Mixins::HasRowCalculations

  validates_with FileValidator, attachment: :document, file_size_in_megabytes: 2

  scope :with_includes, -> {includes(:created_by, :updated_by, :inquiry)}

  def filename(include_extension: false)
    [
        ['po', po_number].join('_'),
        ('pdf' if include_extension)
    ].compact.join('.')
  end
end
