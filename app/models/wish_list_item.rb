class WishListItem < ApplicationRecord
  belongs_to :wish_list
  belongs_to :product
end
