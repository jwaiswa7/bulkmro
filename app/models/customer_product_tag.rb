class CustomerProductTag < ApplicationRecord
  belongs_to :tag
  belongs_to :customer_product
end
