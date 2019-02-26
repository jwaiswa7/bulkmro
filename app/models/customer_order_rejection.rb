# frozen_string_literal: true

class CustomerOrderRejection < ApplicationRecord
  include Mixins::Customers::CanBeStamped

  belongs_to :customer_order
end
