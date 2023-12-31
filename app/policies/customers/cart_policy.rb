# frozen_string_literal: true

class Customers::CartPolicy < Customers::ApplicationPolicy
  def show?
    contact.customer_products.exists? && !vertiv?
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

  def update_cart_details?
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

  def add_item? 
    return false if vertiv?
    true
  end

  def punchout?
    show?
  end

  def punchout_cart?
    punchout?
  end

  def manual_punchout?
    show?
  end

  private 
  def vertiv?  
		contact.account_id == 2478
	end
end
