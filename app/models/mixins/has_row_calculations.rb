module Mixins::HasRowCalculations
  extend ActiveSupport::Concern

  included do
    def calculated_total
      rows.map {|row| row.total_selling_price}.sum
    end

    def calculated_total_tax
      rows.map {|row| row.total_tax}.sum
    end

    def calculated_total_with_tax
      rows.map {|row| row.total_selling_price_with_tax}.sum
    end

    def calculated_total_margin
      rows.map {|row| row.total_margin}.sum
    end

    def calculated_total_margin_percentage
      ((calculated_total - calculated_total_cost) / calculated_total) * 100
    end

    def calculated_total_cost
      rows.map {|row| (row.unit_cost_price_with_unit_freight_cost * row.quantity)}.sum
    end

    def calculated_freight_cost_total
      rows.sum(:freight_cost_subtotal).to_f
    end

    def calculated_total_qty
      rows.map {|row| row.quantity}.sum
    end
  end
end