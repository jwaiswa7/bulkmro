class Brand < ApplicationRecord
  belongs_to :company
  has_many :products
end
