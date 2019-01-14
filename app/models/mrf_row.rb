class MrfRow < ApplicationRecord
  belongs_to :material_readiness_followup
  belongs_to :purchase_order_row
end
