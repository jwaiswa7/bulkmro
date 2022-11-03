class WishList < ApplicationRecord
  belongs_to :contact 
  belongs_to :company, required: false
  has_many :items, class_name: "WishListItem", dependent: :destroy
end
