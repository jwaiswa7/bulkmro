class ProductApproval < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :product
end
