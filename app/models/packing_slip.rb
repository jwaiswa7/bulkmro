class PackingSlip < ApplicationRecord
  belongs_to :outward_dispatch, required: false
  has_many :rows, class_name: 'PackingSlipRow', inverse_of: :packing_slip, dependent: :destroy
  include Mixins::CanBeStamped
  accepts_nested_attributes_for :rows, reject_if: lambda { |attributes| attributes['ar_invoice_request_row_id'].blank? && attributes['id'].blank? }, allow_destroy: true
  validate :box_number_uniq?



  def dispatched_quantity
    self.rows.sum(:delivery_quantity)
  end

  def box_number_uniq?
    box_uniq = PackingSlip.where(outward_dispatch_id: self.outward_dispatch_id).pluck(:box_number)
    if box_uniq.include?(box_number)
      errors.add(:box_number, "#{box_number} already exists in this outward dispatch.")
    end
  end

  def filename(include_extension: false)
    [
        ['packing_slip', id].join('_'),
        ('pdf' if include_extension)
    ].compact.join('.')
  end
end
