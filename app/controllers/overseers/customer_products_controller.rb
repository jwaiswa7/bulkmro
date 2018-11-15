class Overseers::CustomerProductsController < Overseers::BaseController

  def index
    @products = ApplyDatatableParams.to(CustomerProduct.all, params)
    authorize @products
  end

  def autocomplete
    account = Account.find(params[:account_id]) if params[:account_id].present?
    company = Company.find(params[:company_id]) if params[:company_id].present?
    customer_products = (account || company).customer_products

    @products = ApplyParams.to(customer_products, params)
    authorize @products
  end
end