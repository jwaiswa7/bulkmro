class Overseers::ReviewQuestionsController < Overseers::BaseController
  before_action :set_review_question, only: [:show, :edit, :update, :destroy]

  # GET /review_questions
  # GET /review_questions.json
  def index
    @review_questions = ApplyDatatableParams.to(ReviewQuestion.all.includes(:created_by), params)
    authorize @review_questions
  end

  # GET /review_questions/1
  # GET /review_questions/1.json
  def show
    authorize @review_question
  end

  # GET /review_questions/new
  def new
    @review_question = ReviewQuestion.new
    authorize @review_question

  end

  # GET /review_questions/1/edit
  def edit
    authorize @review_question
  end

  # POST /review_questions
  # POST /review_questions.json
  def create
    @review_question = ReviewQuestion.new(review_question_params)
    authorize @review_question
    if @review_question.save
      redirect_to overseers_review_questions_path, notice: flash_message(@review_question, action_name)
    else
      render 'new'
    end
  end

  # PATCH/PUT /review_questions/1
  # PATCH/PUT /review_questions/1.json
  def update
    authorize @review_question
    if @review_question.save
      redirect_to overseers_review_questions_path(@review_question), notice: flash_message(@review_question, action_name)
    else
      render 'edit'
    end
  end

  # DELETE /review_questions/1
  # DELETE /review_questions/1.json
  def destroy
    authorize @review_question
    company_rating = CompanyRating.where(:review_question_id => @review_question.id )
    if !company_rating.present?
      @review_question.destroy!
      redirect_to overseers_review_questions_url, notice: flash_message(@review_question, action_name)
    else
      redirect_to overseers_review_questions_url, notice: "Cannot delete this review question already in used."
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_review_question
    @review_question = ReviewQuestion.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def review_question_params
    params.require(:review_question).permit(:question, :weightage, :question_type)
  end
end
