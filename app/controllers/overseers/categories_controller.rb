

class Overseers::CategoriesController < Overseers::BaseController
  before_action :set_category, only: [:edit, :update, :show]

  def autocomplete
    @categories = ApplyParams.to(Category.leaves.active, params)
    authorize @categories
  end

  def autocomplete_closure_tree
    @categories = []
    ApplyParams.to(Category.where('is_active = ? and is_service = ?', true, params[:is_service]).where.not(id: Category.default.id), params).each do |grandparent|
      @categories << get_category_hash(grandparent, :grandparent)
      grandparent.children.each do |parent|
        @categories << get_category_hash(parent, :parent)
        parent.children.each do |child|
          @categories << get_category_hash(child, :child)
        end
      end
    end
    authorize :category
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

    def get_category_hash(category, level = :child)
      {
          id: category.id,
          text: category.autocomplete_to_s(level)
      }
    end

    def category_params
      params.require(:category).permit(
        :parent_id,
          :name,
          :is_service,
          :is_active,
          :tax_code_id,
          :tax_rate_id
      )
    end

    def set_category
      @category = Category.find(params[:id])
    end
end
