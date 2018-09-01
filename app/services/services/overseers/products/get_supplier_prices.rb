class Services::Overseers::Products::GetSupplierPrices < Services::Shared::BaseService

  def initialize(product, supplier)
    @product = product
    @supplier = supplier
  end

  def call
    response = [:lowest_price => "N/A", :latest_price => "N/A"]
    if product.present? && product.approved?
      if product.inquiry_suppliers.present?
        response = [:lowest_price => product.lowest_unit_cost_price_for(supplier), :latest_price => product.latest_unit_cost_price_for(supplier)]
      end
    end

    response
  end

  attr_accessor :product, :supplier
end