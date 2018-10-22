class Overseers::CategoriesController < Overseers::BaseController
  before_action :set_category, :only => [:edit, :update, :show]

  def autocomplete
    @categories = ApplyParams.to(Category.leaves, params)
    authorize @categories
  end

  def autocomplete_closure_tree
    calling_category = Category.find(params[:calling_category_id]) if params[:calling_category_id].present?
    @categories = ApplyParams.to(Category.except_self_and_children(calling_category).leaves, params)
    authorize @categories
  end

  def show
    authorize @category
  end

  def index
    @categories = ApplyDatatableParams.to(Category.all, params)
    authorize @categories
  end

  def new
    @category = Category.new(overseer: current_overseer)
    authorize @category
  end

  def create
    @category = Category.new(category_params.merge(overseer: current_overseer))
    authorize @category
    if @category.save_and_sync
      redirect_to overseers_categories_path, notice: flash_message(@category, action_name)
    else
      render 'new'
    end
  end

  def edit
    authorize @category
  end

  def update
    @category.assign_attributes(category_params.merge(overseer: current_overseer))
    authorize @category
    if @category.save_and_sync
      redirect_to overseers_categories_path, notice: flash_message(@category, action_name)
    else
      render 'edit'
    end
  end

  private

  def category_params
    params.require(:category).permit(
        :parent_id,
        :name,
        :is_service
    )
  end

  def set_category
    @category = Category.find(params[:id])
  end
end