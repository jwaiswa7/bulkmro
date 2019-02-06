module Mixins::CanBeTotalled
  extend ActiveSupport::Concern

  included do
    def calculated_total
      items.inject(0) {|sum, item| sum + item.customer_product.customer_price.to_f * item.quantity}
    end

    def tax_line_items(params=nil)
      grouped_items = (params == "from_order_rows") ? items.group_by(&:tax_rate) : items.joins(:customer_product).group_by(&:best_tax_rate)
      tax_items = {}

      grouped_items.each do |tax_rate, items|
        tax_items[tax_rate.tax_percentage.to_f] ||= 0

        tax_items[tax_rate.tax_percentage.to_f] += items.map do |item|
          item.quantity * item.customer_product.customer_price * tax_rate.tax_percentage.to_f / 100
        end.sum
      end

      tax_items
    end

    def calculated_total_tax(params=nil)
      items.map do |item|
        tax_percentage = (params == "from_order_rows") ? item.tax_rate.tax_percentage : item.customer_product.best_tax_rate.tax_percentage
        item.customer_product.customer_price * item.quantity * tax_percentage / 100
      end.sum
    end

    def grand_total(params=nil)
      calculated_total + calculated_total_tax(params)
    end

    def default_warehouse_address
      Warehouse.default.address
    end
  end
end