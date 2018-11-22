class Cart < ApplicationRecord
	belongs_to :contact
	has_many :items, class_name: 'CartItem', dependent: :destroy
  accepts_nested_attributes_for :items
end
