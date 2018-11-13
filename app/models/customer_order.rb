class CustomerOrder < ApplicationRecord
  belongs_to :contact
  has_many :rows, dependent: :destroy, class_name: 'CustomerOrderRow'
end
