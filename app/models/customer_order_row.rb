# frozen_string_literal: true

class CustomerOrderRow < ApplicationRecord
  belongs_to :customer_product
  belongs_to :product
  belongs_to :tax_code, required: false
  belongs_to :tax_rate, required: false
  delegate :best_tax_rate, to: :customer_product

  def unit_selling_price
    self.customer_product.customer_price.to_f
  end

  def total_selling_price
    self.customer_product.customer_price.to_f * self.quantity
  end
end
