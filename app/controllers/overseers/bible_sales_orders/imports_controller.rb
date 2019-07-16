class Overseers::BibleSalesOrders::ImportsController < Overseers::BaseController
  def new_excel_bible_order_import
    # binding.pry
    # render 'new_excel_bible_order_import'
    # @bible_order_import = @company.product_imports.build(overseer: current_overseer)
    authorize_acl :bible_sales_order
  end

  def download_bible_order_template
    # authorize_acl @bible_sales_orders
    # respond_to do |format|
    #   format.xlsx do
    #     response.headers['Content-Disposition'] = 'attachment; filename="' + ["#{@company.name} Excel Template", 'xlsx'].join('.') + '"'
    #   end
    # end
  end

  def create_bible_orders
    # @product_excel_import = @company.product_imports.build(create_excel_import_params.merge(import_type: :list, overseer: current_overseer))
    # service = Services::Overseers::CustomerProductsImports::ExcelImporter.new(@company, @product_excel_import)
    # import = service.call
    # if import.errors.messages.present?
    #   redirect_to new_excel_customer_product_import_overseers_company_imports_path(@company), notice: import.errors.full_messages.first
    # else
    #   redirect_to overseers_company_path(@company)
    # end
    # authorize_acl @bible_sales_orders
  end

  # def create_excel_import_params
  #   params.require(:bible_order_import).permit(
  #       :file
  #   )
  # end
end




