class Customers::CheckoutController < Customers::BaseController
  def final_checkout
    authorize :checkout
    @cart = current_cart
  end

  def show
    authorize :checkout
    redirect_to customers_cart_path
  end

  def customer_po_autocomplete
    authorize :checkout
    @customer_pos = ApplyParamsToArray.to(Inquiry.where(company_id: current_company.id).where.not(customer_po_number: "").map(&:customer_po_number)&.uniq&.compact, params)
    
  end
end
