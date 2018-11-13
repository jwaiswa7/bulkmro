class Cart < ApplicationRecord
	belongs_to :contact
	has_many :items, class_name: 'CartItem', dependent: :destroy
end
