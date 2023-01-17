class Overseers::ProductImportsController < Overseers::BaseController
  def new
    @product_import = ProductImport.new 
    authorize @product_import
  end


  def create
    @product_import = ProductImport.new(product_import_params.merge(overseer: current_overseer))
    authorize @product_import
    if @product_import.save 
      ProductImportJob.perform_later(@product_import.id)
      redirect_to overseers_products_path, notice: 'Processing upload'
    else
      render :new
    end
  end

  def excel_template
    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = 'attachment; filename="product_uploads_template.xlsx"'
      }
    end
  end


    private

      def product_import_params
        params.require(:product_import).permit(:file)
      end
end
