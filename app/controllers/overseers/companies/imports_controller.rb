class Overseers::Companies::ImportsController < Overseers::Companies::BaseController
  def new_excel_customer_product_import
    @product_excel_import = @company.product_imports.build(overseer: current_overseer)
    authorize @company
  end

  def download_customer_product_template
    authorize @company
    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = 'attachment; filename="' + ["#{@company.name.to_s} Excel Template", 'xlsx'].join('.') + '"'
      }
    end
  end

  def create_customer_products
    @product_excel_import = @company.product_imports.build(create_excel_import_params.merge(import_type: :list,overseer: current_overseer))
    service = Services::Overseers::CustomerProductsImports::ExcelImporter.new(@company, @product_excel_import)
    service.call
    authorize @company
    redirect_to overseers_company_path(@company)
  end

  def create_excel_import_params
    params.require(:customer_product_import).permit(
        :file
    )
  end
end