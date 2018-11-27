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

end