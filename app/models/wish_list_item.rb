# frozen_string_literal: true

class WishListItem < ApplicationRecord
  belongs_to :customer_product
  belongs_to :product
  belongs_to :wish_list
end
