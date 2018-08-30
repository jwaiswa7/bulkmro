class ProductComment < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :product
  has_one :approval, class_name: 'ProductApproval'

  validates_presence_of :message
end
