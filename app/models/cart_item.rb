class CartItem < ApplicationRecord
  belongs_to :customer_product
  belongs_to :product
  belongs_to :cart
end