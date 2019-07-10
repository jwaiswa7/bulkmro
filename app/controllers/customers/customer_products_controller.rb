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
    account = Account.find(7)
    service = Services::Customers::Finders::CustomerProducts.new(params, current_contact, current_company)
    service.call
    @indexed_customer_products = service.indexed_records
    @customer_products = service.records.try(:reverse)
    @is_henkel = (current_company.account == account)
    @default_quantity = nil
    if @is_henkel
      @default_quantity = 0
    end

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
    @account = Account.find(7)
    @default_quantity = @customer_product.moq
    @is_henkel = (current_company.account == @account)
    @display_class = ''
    if @is_henkel
      @default_quantity = 0
      @display_class = (@customer_product.product.stocks.sum(&:instock) > 0) ? '' : 'd-none'
    end
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
