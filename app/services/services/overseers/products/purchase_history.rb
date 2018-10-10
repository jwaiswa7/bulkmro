class Services::Overseers::Products::PurchaseHistory < Services::Overseers::Finders::BaseFinder

  def initialize(product)
    @product = product
  end

  def call
    call_base
  end

  def model_klass
    Product
  end

  def inquiry_products_list
    @product.inquiry_products
  end

end
