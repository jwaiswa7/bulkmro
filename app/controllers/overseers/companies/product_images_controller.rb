class Overseers::Companies::ProductImagesController < Overseers::Companies::BaseController
  def new 
    @product_image = ProductImage.new
  end

  def create 
    to_upload.each do |image|
      sku = image.original_filename.split(".").first
      customer_product = CustomerProduct.find_by(sku: sku)
      customer_product.images.attach(image)
    end
    
    if invalid_images.count.positive?
      @product_image = ProductImage.new
      @product_image.invalid_uploads = invalid_images
      render 'new'
    else  
      redirect_to overseers_company_path(@company)
    end
    
  end

  private

  def uploaded_images
    params.require(:product_image)[:image]
  end
  
  # gets the uploaded file names
  def file_names 
    uploaded_images.map{ |image| image.original_filename.split(".").first }
  end
  
  # File names of invalid images, these are images with the sku not available in the customer product images
  def invalid_images
    skus = @company.customer_products.where(sku: file_names).map(&:sku)
    file_names - skus 
  end
  
  # Get the files to uplod to AWS
  def to_upload 
    return uploaded_images if invalid_images.count.zero?
    uploaded_images.map { |image| image unless invalid_images.include? image.original_filename.split(".").first }.compact!
  end
end
  