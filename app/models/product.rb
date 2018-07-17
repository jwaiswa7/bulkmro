class Product < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :brand
end
