class Services::Overseers::Inquiries::MassUploader < Services::Shared::BaseService
  def initialize(inquiry, excel_import, product_params, current_overseer)
    @inquiry = inquiry
    @excel_import = excel_import
    @product_params = product_params
    @current_overseer = current_overseer
  end

  def call
    products = []
    product_params.each do |index, p|
      p = p.permit(:name, :sku, :brand_id, :category_id)
      product = Product.new(p)
      product.created_by = @current_overseer
      product.updated_by = @current_overseer
      product.save
      products << product

      @excel_import.failed_skus.delete(p[:sku])
      #remove from Failed
      #add_to_queue
      #notify
    end

    service = Services::Overseers::Inquiries::ExcelImporter.new(@inquiry, @excel_import)
    service.call

  end

  def notify

  end

  def has_empty_values(set)
    set.collect {|e| e.to_s.empty?}.include?(true)
  end

  attr_accessor :inquiry, :excel_import, :product_params
end