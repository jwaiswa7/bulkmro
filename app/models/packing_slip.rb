class PackingSlip < ApplicationRecord
  belongs_to :outward_dispatch, default: false
  has_many :rows, class_name: 'PackingSlipRow', inverse_of: :packing_slip
  include Mixins::CanBeStamped

end
