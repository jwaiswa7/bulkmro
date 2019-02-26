# frozen_string_literal: true

class CustomerOrderRow < ApplicationRecord
  belongs_to :customer_product
  belongs_to :product
  belongs_to :tax_code
  belongs_to :tax_rate
  delegate :best_tax_rate, to: :customer_product
end
