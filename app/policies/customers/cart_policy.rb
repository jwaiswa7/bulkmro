

class Customers::CartPolicy < Customers::ApplicationPolicy
  def show?
    contact.customer_products.exists?
  end

  def checkout?
    show?
  end

  def empty_cart?
    true
  end

  def update_cart?
    true
  end

  def update_billing_address?
    true
  end

  def update_shipping_address?
    true
  end

  def update_special_instructions?
    true
  end

  def update_payment_method?
    true
  end

  def update_payment_data?
    true
  end

  def add_po_number?
    true
  end
end
