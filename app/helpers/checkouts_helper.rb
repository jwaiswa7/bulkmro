module CheckoutsHelper
  def order_total(cart_items)
    cart_items.inject(0){|sum, cart_item| sum + cart_item.product.latest_unit_cost_price.to_f * cart_item.quantity}
  end
end