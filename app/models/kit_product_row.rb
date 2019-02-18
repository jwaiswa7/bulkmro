# frozen_string_literal: true

class KitProductRow < ApplicationRecord
  belongs_to :product
  belongs_to :kit
  belongs_to :tax_code
  belongs_to :tax_rate

  # delegate :unit_cost_price, :to => :inquiry_product_supplier, allow_nil: false
  accepts_nested_attributes_for :product

  after_initialize :set_defaults, if: :new_record?

  def set_defaults
    if product.present?
      tax_code ||= product.tax_code
      tax_rat ||= product.tax_rate
    end
  end

  def best_tax_code
    tax_code || product.best_tax_code
  end

  def best_tax_rate
    tax_rate || product.best_tax_rate
  end
end
