class WarehouseProductStock < ApplicationRecord
  belongs_to :product
  belongs_to :warehouse

  scope :total_qty, -> {sum(:instock)}

end
