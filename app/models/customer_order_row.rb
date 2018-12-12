class CustomerOrderRow < ApplicationRecord
  belongs_to :customer_product
  belongs_to :product
end
