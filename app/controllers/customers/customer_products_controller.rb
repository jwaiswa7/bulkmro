class Customers::CustomerProductsController < Customers::BaseController
  before_action :set_customer_product, only: [:show, :to_cart]

  def index
    authorize :customer_product

    if params[:view] == 'list_view'
      params[:per] = 20
    else
      params[:page] = 1 unless params[:page].present?
      params[:per] = 24
    end
    @henkel_company = Account.find(7).companies.pluck(:id)
    service = Services::Customers::Finders::CustomerProducts.new(params, current_contact, current_company)
    service.call
    @indexed_customer_products = service.indexed_records
    @customer_products = service.records.try(:reverse)


    @tags = CustomerProduct.all.map(&:tags).flatten.uniq.collect{ |t| [t.id, t.name] }
    @checked_tags = (params['custom_filters']['tags'].nil? ? [] : params['custom_filters']['tags'].map(&:to_i)) if params['custom_filters'].present?

    @customer_products_paginate = @indexed_customer_products.page(params[:page]) if params[:page].present?
  end

  def autocomplete
    service = Services::Overseers::Finders::CustomerProducts.new(params.merge(page: 1))
    service.call

    @indexed_customer_products = service.indexed_records
    @customer_products = service.records
    authorize @customer_products
  end

  def show
    authorize @customer_product
  end

  def most_ordered_products
    authorize :customer_product

    skip_skus = ['BM9L3P1', 'BM9C4L6']
    skip_product_ids = Product.where('sku ILIKE ANY ( array[?] )', skip_skus).uniq.pluck(:id)

    products = Inquiry.joins(:inquiry_products).where(company: current_company).top(:product_id, 55).reject{ |op, count| op.in?(skip_product_ids) } # nil top returns all
    @total_products = products.size
    @most_ordered_products = products.drop(5).map { |id, c| [Product.find(id), [c, 'times'].join(' ')] }
  end

  private

    def set_customer_product
      @customer_product ||= CustomerProduct.find(params[:id])
    end
end
