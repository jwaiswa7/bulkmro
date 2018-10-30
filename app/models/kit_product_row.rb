class KitProductRow < ApplicationRecord
  belongs_to :product
  belongs_to :kit

  delegate :unit_cost_price, :to => :inquiry_product_supplier, allow_nil: false
end
