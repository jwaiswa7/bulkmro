class CartItem < ApplicationRecord
  belongs_to :customer_product
  belongs_to :product
  belongs_to :cart

  validate :check_quantity

  def check_quantity
    if quantity % customer_product.moq != 0
      errors.add(:quantity, "should be in multiples of the MOQ of the product")
    end
  end
end