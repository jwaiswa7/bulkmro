class PackingSlip < ApplicationRecord
  belongs_to :material_dispatch, default: false
  has_many :packing_slip_rows
end
