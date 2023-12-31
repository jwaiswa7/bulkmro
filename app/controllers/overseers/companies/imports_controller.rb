# frozen_string_literal: true

class Overseers::Companies::ImportsController < Overseers::Companies::BaseController
  def new_excel_customer_product_import
    @product_excel_import = @company.product_imports.build(overseer: current_overseer)
    authorize_acl @company
  end

  def download_customer_product_template
    authorize_acl @company
    respond_to do |format|
      format.xlsx do
        response.headers['Content-Disposition'] = 'attachment; filename="' + ["#{@company.name} Excel Template", 'xlsx'].join('.') + '"'
      end
    end
  end

  def create_customer_products
    @product_excel_import = @company.product_imports.build(create_excel_import_params.merge(import_type: :list, overseer: current_overseer))
    service = Services::Overseers::CustomerProductsImports::ExcelImporter.new(@company, @product_excel_import)
    import = service.call
    if import.errors.messages.present?
      redirect_to new_excel_customer_product_import_overseers_company_imports_path(@company), notice: import.errors.full_messages.first
    else
      redirect_to overseers_company_path(@company)
    end
    authorize_acl @company
  end

  def create_excel_import_params
    params.require(:customer_product_import).permit(
      :file
    )
  end
end
