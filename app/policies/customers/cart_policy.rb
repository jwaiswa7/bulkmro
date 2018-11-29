class Customers::CartPolicy < Customers::ApplicationPolicy
  def checkout?
    show?
  end

  def empty_cart?
    true
  end

  def update_billing_address?
    true
  end

  def update_shipping_address?
    true
  end

  def add_po_number?
    true
  end
end