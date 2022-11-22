class Customers::Companies::AddressesController < Customers::Companies::BaseController

  def autocomplete
    @addresses = ApplyParams.to(@company.addresses.includes(:state), params)
    authorize @addresses
  end

  def customer_po_autocomplete
    authorize :checkout
    @customer_pos = ApplyParamsToArray.to(Inquiry.where(company_id: @company.id).where.not(customer_po_number: "").map(&:customer_po_number)&.uniq&.compact, params)
  end

end