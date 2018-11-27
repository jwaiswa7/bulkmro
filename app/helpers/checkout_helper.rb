module CheckoutHelper

  def get_order_total(cart_items)
    cart_items.inject(0){|sum, cart_item| sum + cart_item.product.latest_unit_cost_price.to_f * cart_item.quantity}
  end

  def get_billing_address(billing_address_id)
    Address.find(billing_address_id).to_multiline_s
  end

  def get_shipping_address(shipping_address_id)
    Address.find(shipping_address_id).to_multiline_s
  end

  def get_gst_no(address_id)
    Address.find(address_id).gst
  end

  #refactoring pending
  def calculate_tax(cart_items)
    items = cart_items.joins(:product).select("tax_rate_id as tax_rate_id, product_id as product_id, quantity as quantity")
    items.each_with_object({}) do |item, hash|
      if item.tax_rate_id.present?
        if hash.has_key? item.tax_rate_id
          hash[get_tax_percentage(item.tax_rate_id)] += ((item.product.latest_unit_cost_price.to_f * item.quantity) * get_tax_percentage(item.tax_rate_id) / 100)
        else
          hash[get_tax_percentage(item.tax_rate_id)] = ((item.product.latest_unit_cost_price.to_f * item.quantity) * get_tax_percentage(item.tax_rate_id) / 100)
        end
      end
    end
  end

  def total_tax(cart_items)
    if calculate_tax(cart_items).empty?
      0
    else
      calculate_tax(cart_items).values.inject{|a,b| a + b}
    end
  end

  def grand_total(cart_items)
    get_order_total(cart_items) + total_tax(cart_items)
  end

  def get_tax_percentage(tax_rate_id)
    TaxRate.find(tax_rate_id).tax_percentage.to_f
  end
end