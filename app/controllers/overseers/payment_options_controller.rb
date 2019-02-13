class Overseers::PaymentOptionsController < Overseers::BaseController
  before_action :set_payment_option, only: [:edit, :show, :update]

  def index
    @payment_options = ApplyDatatableParams.to(PaymentOption.all, params)
    authorize @payment_options
  end

  def new
    @payment_option = PaymentOption.new(overseer: current_overseer)
    authorize @payment_option
  end

  def create
    @payment_option = PaymentOption.new(payment_option_params.merge(overseer: current_overseer))
    authorize @payment_option
    if @payment_option.save_and_sync
      redirect_to overseers_payment_option_path(@payment_option), notice: flash_message(@payment_option, action_name)
    else
      puts payment_option_params
    end
  end

  def edit
    authorize @payment_option
  end

  def update
    @payment_option.assign_attributes(payment_option_params.merge(overseer: current_overseer))
    authorize @payment_option
    if @payment_option.save_and_sync
      redirect_to overseers_payment_option_path(@payment_option), notice: flash_message(@payment_option, action_name)
    else
      render "edit"
    end
  end

  def show
    authorize @payment_option
  end

  private

    def payment_option_params
      params.require(:payment_option).permit(
        :name,
          :credit_limit,
          :general_discount,
          :load_limit
      )
    end

    def set_payment_option
      @payment_option ||= PaymentOption.find(params[:id])
    end
end
