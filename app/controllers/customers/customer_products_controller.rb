class Customers::CustomerProductsController < Customers::BaseController
  before_action :set_customer_product, only: [:show, :to_cart]
  before_action :create_new_cart_item, only: [:index, :to_cart, :show]

  def index
    authorize :customer_product

    if params[:view] == 'list_view'
      params[:per] = 20
    else
      params[:page] = 1 unless params[:page].present?
      params[:per] = 24
    end

    service = Services::Customers::Finders::CustomerProducts.new(params, current_contact)
    service.call

    @indexed_customer_products = service.indexed_records
    @customer_products = service.records.try(:reverse)
    @customer_products_paginate = @indexed_customer_products.page(params[:page]) if params[:page].present?
  end

  def autocomplete
    service = Services::Overseers::Finders::CustomerProducts.new(params.merge(page: 1))
    service.call

    @indexed_customer_products = service.indexed_records
    @customer_products = service.records
    authorize @customer_products
  end

  def to_cart
    authorize @customer_product

    respond_to do |format|
      format.js {render :partial => "customers/cart/add_to_cart.js.erb"}
    end
  end

  def show
    authorize @customer_product
  end

  def most_ordered_products
    authorize :product

    @total_products = products().size
    @most_ordered_products = products(top: 55).drop(5).map {|id, c| [Product.find(id), [c, 'times'].join(' ')]}
  end

  private

  def set_customer_product
    @customer_product ||= CustomerProduct.find(params[:id])
  end

  def create_new_cart_item
    @cart_item = CartItem.new
  end

  def products(top: nil)
    Inquiry.joins(:inquiry_products).where(:company => current_contact.companies).top(:product_id, top) # nil top returns all
  end
end
