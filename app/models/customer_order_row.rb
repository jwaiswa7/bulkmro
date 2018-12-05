class CustomerOrderRow < ApplicationRecord
  belongs_to :product
  belongs_to :customer_product
end
