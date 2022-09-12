class Overseers::Companies::ProductImagesController < Overseers::Companies::BaseController
  def new 
    @product_image = ProductImage.new
  end

  def create 
    redirect_to overseers_company_path(@company), notice: "Upload successful"
  end

  private

  def product_image_params
    params.require(:product_image)
  end
end
  