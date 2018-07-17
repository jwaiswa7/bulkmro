class Brand < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :company
  has_many :products
end
