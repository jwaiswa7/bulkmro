class Services::Overseers::Finders::PurchaseHistory < Services::Overseers::Finders::BaseFinder

  def initialize(params)
    @id = params[:id]
  end

  def call
    call_base
  end

  def get_product
    Product.find("#{@id}")
  end

  def model_klass
    Product
  end

  def product_inquiries_list
    product = get_product
    product.inquiry_products
  end

end
