class Overseers::Inquiries::ImportsController < Overseers::Inquiries::BaseController
  before_action :set_import, only: [:show]

  def new_excel_import
    @import = @inquiry.imports.build(import_type: :excel, overseer: current_overseer)
    authorize @inquiry
  end

  def new_list_import
    @import = @inquiry.imports.build(import_type: :list, overseer: current_overseer)
    authorize @inquiry
  end

  def create
    @import = @inquiry.imports.build(import_params.merge(overseer: current_overseer))
    authorize @inquiry, :create_import?
    @import.save

    redirect_to edit_overseers_inquiry_path(@inquiry), notice: flash_message(@inquiry, action_name)
  end

  def index
    @imports = @inquiry.imports
    authorize @inquiry, :imports_index?
  end

  def show
    authorize @inquiry, :show_import?

    respond_to do |format|
      format.text { render plain: @import.import_text }
    end
  end

  private
  def set_import
    @import = @inquiry.imports.find(params[:id])
  end

  def import_params
    params.require(:inquiry_import).permit(
      :import_type,
      :import_text
    )
  end
end