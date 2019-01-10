class MrfRow < ApplicationRecord
  belongs_to :material_readiness_followup

  enum status: {
    :'Material Readiness Follow-Up' => 10,
    :'Material Pickup' => 20,
    :'Material Delivered' => 30
  }, _prefix: true
end
