class Overseers::Companies::TagsController < Overseers::Companies::BaseController
  before_action :set_tag, only: [:show, :edit, :update, :destroy]

  def index
    @tags = ApplyDatatableParams.to(@company.tags, params.reject! { |k, v| k == 'company_id' })
    authorize_acl @tags
  end

  def autocomplete
    company = Company.find(params[:company_id]) if params[:company_id].present?
    tags = company.tags

    @tags = ApplyParams.to(tags, params)
    authorize_acl @tags
  end

  def show
    authorize_acl @tag
  end

  def new
    @tag = @company.tags.new(overseer: current_overseer)
    authorize_acl @tag
  end

  def create
    @tag = @company.tags.where(name: tag_params[:name]).first_or_initialize

    authorize_acl @tag

    if @tag.save
      redirect_to overseers_company_tag_path(@company, @tag), notice: flash_message(@tag, action_name)
    else
      render 'edit'
    end
  end

  def edit
    authorize_acl @tag
  end

  def update
    @tag.assign_attributes(tag_params)

    authorize_acl @tag

    if @tag.save
      redirect_to overseers_company_tag_path(@tag.company, @tag), notice: flash_message(@tag, action_name)
    else
      render 'edit'
    end
  end

  def destroy
    authorize_acl @tag
    @tag.destroy!

    redirect_to overseers_company_path(@company)
  end

  private

    def set_tag
      @tag ||= Tag.find(params[:id])
    end

    def tag_params
      params.require(:tag).permit(
        :name,
          :company_id,
      )
    end
end
