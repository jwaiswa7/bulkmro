class SalesShipment < ApplicationRecord
  include Mixins::CanBeSynced
  include Mixins::CanBeStamped

  belongs_to :sales_order
  has_many :rows, :class_name => 'SalesShipmentRow', inverse_of: :sales_shipment
  has_many :packages, :class_name => 'SalesShipmentPackage', inverse_of: :sales_shipment
  has_many :comments, :class_name => 'SalesShipmentComment', inverse_of: :sales_shipment

  has_one_attached :shipment_pdf

  enum status: {
      default: 10,
      cancelled: 20
  }, _prefix: true

  validates_presence_of :status
  validates_with FileValidator, attachment: :shipment_pdf, file_size_in_megabytes: 2

  after_initialize :set_defaults, :if => :new_record?

  def set_defaults
    self.status ||= :default
  end

  def filename(include_extension: false)
    [
        ['shipment', shipment_number].join('_'),
        ('pdf' if include_extension)
    ].compact.join('.')
  end
end
