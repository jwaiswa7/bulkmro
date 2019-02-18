# frozen_string_literal: true

module Mixins::HasConvertedCalculations
  extend ActiveSupport::Concern

  included do
    def calculated_total
      rows.map(&:total_selling_price).sum.round(2)
    end

    def calculated_total_tax
      rows.map(&:total_tax).sum.round(2)
    end

    def calculated_total_with_tax
      rows.map(&:total_selling_price_with_tax).sum.round(2)
    end

    def calculated_total_margin
      rows.map(&:total_margin).sum.round(2)
    end

    def calculated_total_margin_percentage
      (((calculated_total - calculated_total_cost) / calculated_total) * 100).round(2) if calculated_total > 0
    end

    def calculated_total_cost
      rows.map { |row| (row.unit_cost_price_with_unit_freight_cost * row.quantity) }.sum.round(2)
    end

    def calculated_freight_cost_total
      rows.sum(:freight_cost_subtotal).round(2)
    end

    def calculated_total_cost_without_freight
      calculated_total_cost - calculated_freight_cost_total
    end

    def calculated_total_quantity
      rows.map(&:quantity).sum.round(2)
    end

    # Considers conversion rate for totals
    def converted_total
      (calculated_total / inquiry_currency.conversion_rate).round(2)
    end

    def converted_total_tax
      (calculated_total_tax / inquiry_currency.conversion_rate).round(2)
    end

    def converted_total_with_tax
      (calculated_total_with_tax / inquiry_currency.conversion_rate).round(2)
    end

    def converted_total_margin
      (calculated_total_margin / inquiry_currency.conversion_rate).round(2)
    end

    def converted_total_cost
      (calculated_total_cost / inquiry_currency.conversion_rate).round(2)
    end

    def converted_freight_cost_total
      (calculated_freight_cost_total / inquiry_currency.conversion_rate).round(2)
    end
  end
end
