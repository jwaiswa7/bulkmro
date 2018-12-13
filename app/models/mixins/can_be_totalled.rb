module Mixins::CanBeTotalled
  extend ActiveSupport::Concern

  included do
    def calculated_total
      items.inject(0) {|sum, item| sum + item.customer_product.customer_price.to_f * item.quantity}
    end

    def tax_line_items
      grouped_items = items.joins(:customer_product).group_by(&:best_tax_rate)
      tax_items = {}

      grouped_items.each do |tax_rate, items|
        tax_items[tax_rate.tax_percentage.to_f] ||= 0

        tax_items[tax_rate.tax_percentage.to_f] += items.map do |item|
          item.quantity * item.customer_product.customer_price * tax_rate.tax_percentage.to_f / 100
        end.sum
      end

      tax_items
    end

    def calculated_total_tax
      items.map do |item|
        item.customer_product.customer_price * item.quantity * item.customer_product.best_tax_rate.tax_percentage / 100
      end.sum
    end

    def grand_total
      calculated_total + calculated_total_tax
    end
  end
end