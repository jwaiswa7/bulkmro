class Overseers::CategoriesController < Overseers::BaseController
  before_action :set_category, :only => [:edit, :update, :show]

  def show
    redirect_to edit_overseers_category_path (@category)
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
    if @category.save
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
    if @category.save
      redirect_to overseers_categories_path, notice: flash_message(@category, action_name)
    end
  end

  private
  def category_params
    params.require(:category).permit(
        :parent_id,
        :name,
    )
  end

  def set_category
    @category = Category.find(params[:id])
  end
end