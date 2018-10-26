class CustomerOrder < ApplicationRecord
  has_many :customer_order_rows, dependent: :destroy
end
