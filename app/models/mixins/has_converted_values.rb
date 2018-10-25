module Mixins::HasConvertedValues
  extend ActiveSupport::Concern

  include HasRowCalculations

  included do
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