class PackingSlip < ApplicationRecord
  belongs_to :outward_dispatch, default: false
  has_many :packing_slip_rows
end
