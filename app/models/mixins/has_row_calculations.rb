module Mixins::HasRowCalculations
  extend ActiveSupport::Concern

  included do
    def calculated_total
      rows.map { |row| row.total_selling_price }.sum
    end

    def calculated_total_tax
      rows.map { |row| row.total_tax }.sum
    end

    def calculated_total_with_tax
      rows.map { |row| row.total_selling_price_with_tax }.sum
    end

    def calculated_total_margin
      rows.map { |row| row.total_margin }.sum
    end

    # def calculated_total_margin_percentage
    #   rows.map { |row| row.margin_percentage }.sum / rows.size
    # end

    def calculated_freight_cost_total
      rows.sum(:freight_cost_subtotal).to_f
    end
  end
end