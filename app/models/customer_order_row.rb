# frozen_string_literal: true

class CustomerOrderRow < ApplicationRecord
  belongs_to :customer_product
  belongs_to :product
  delegate :best_tax_rate, to: :customer_product
end
