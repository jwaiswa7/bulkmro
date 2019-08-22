class Overseers::ReviewQuestionsController < Overseers::BaseController
  before_action :set_review_question, only: [:show, :edit, :update, :destroy]

  def index
    @review_questions = ApplyDatatableParams.to(ReviewQuestion.all.includes(:created_by).order(:question_type), params)
    authorize_acl @review_questions
  end

  def show
    authorize_acl @review_question
  end

  def new
    @review_question = ReviewQuestion.new(overseer: current_overseer)
    authorize_acl @review_question
  end

  def edit
    authorize_acl @review_question
  end

  def create
    @review_question = ReviewQuestion.new(review_question_params)
    authorize_acl @review_question
    if @review_question.save
      redirect_to overseers_review_questions_path, notice: flash_message(@review_question, action_name)
    else
      render 'new'
    end
  end

  def update
    authorize_acl @review_question
    @review_question.assign_attributes(review_question_params.merge(overseer: current_overseer))
    if @review_question.save
      redirect_to overseers_review_question_path(@review_question), notice: flash_message(@review_question, action_name)
    else
      render 'edit'
    end
  end

  def destroy
    authorize_acl @review_question
    company_rating = CompanyRating.where(review_question_id: @review_question.id)
    if !company_rating.present?
      @review_question.destroy!
      redirect_to overseers_review_questions_url, notice: flash_message(@review_question, action_name)
    else
      redirect_to overseers_review_questions_url, notice: 'Cannot delete question used in reviews.'
    end
  end

  private

    def set_review_question
      @review_question = ReviewQuestion.find(params[:id])
    end

    def review_question_params
      params.require(:review_question).permit(:question, :weightage, :question_type)
    end
end
