class Customers::CustomerProductsController < Customers::BaseController
  before_action :set_customer_product, only: [:show, :to_cart]
  before_action :set_view, only: :index
  before_action :set_data_for_saint_gobain, :set_data_for_henkel, only: [:index, :show]
  include DisplayHelper

  def index
    authorize :customer_product

    account = Account.find(2431)
    service = Services::Customers::Finders::CustomerProducts.new(params.merge(published: true), current_customers_contact, current_company, sort_by: sort_by, sort_order: 'desc')
    service.call
    @indexed_customer_products = service.indexed_records
    @customer_products = service.records.with_eager_loaded_images.try(:reverse)
    # for henkel company specific changes
    @is_henkel = (current_company.account == account)

    @default_quantity = nil
    if @is_henkel
      @default_quantity = 0
    end
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
    @account = Account.find(2431)
    @default_quantity = @customer_product.moq
    # for henkel company specific changes
    @is_henkel = (current_company.account == @account)
    @display_class = ''
    if @is_henkel
      @default_quantity = 0
      @display_class = get_instock_status(@customer_product, @phursungi_warehouse) ? '' : 'd-none'
    end

    if @is_saint_gobain
      @display_class = get_instock_status(@customer_product, [@bhiwandi_warehouse, @chennai_warehouse]) ? '' : 'd-none'
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

  def product_details 
    authorize :customer_product
    @product = Product.find(params[:id])
    product_details = {}
    product_details['brand'] = @product.brand.to_s
    product_details['tax_code_id'] = @product.best_tax_code.id
    product_details['tax_rate_id'] = @product.best_tax_rate.id
    product_details['measurement_unit'] = @product.measurement_unit.to_s
    product_details['converted_unit_selling_price'] = @product.latest_unit_cost_price
    product_details['mpn'] = @product.mpn
    product_details['category'] = @product.category.to_s
    render json: product_details
  end


  private

    def set_view
      # @view = @current_company.grid_view? ? 'grid' : 'list'
      @view = if params[:view].present? && params[:view] == 'grid'
        'grid'
      else
        'list'
      end
    end

    def sort_by
      case params[:sort]
      when 'inquiries'
        'inquiries'
      when 'qty_in_stock_desc'
        'qty_in_stock'
      else
        'created_at'
      end
    end

    def set_customer_product
      @customer_product ||= CustomerProduct.find(params[:id])
    end

    def set_data_for_saint_gobain
      authorize :customer_product
      @is_saint_gobain = (current_company.id == 11420)
      @bhiwandi_warehouse = Warehouse.find 'LGVfay'
      @chennai_warehouse = Warehouse.find 'OxGf6R'
    end

    def set_data_for_henkel
      authorize :customer_product
      @phursungi_warehouse = Warehouse.find 'rQJfAO'
    end
end
