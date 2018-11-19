class Overseers::PurchaseOrderQueuesController < Overseers::BaseController
  before_action :set_purchase_order_queue, only: [:show, :edit, :update]

  def index
    @purchase_order_queues = ApplyDatatableParams.to(PurchaseOrderQueue.all.order('id DESC'), params)
    authorize @purchase_order_queues
  end

  def show
    authorize @purchase_order_queue
  end

  def new
    @purchase_order_queue = PurchaseOrderQueue.new(:sales_order => params[:sales_order], :overseer => current_overseer)
    raise
    # @purchase_order_queue.inquiry =
    authorize @purchase_order_queue
  end

  def create
    @purchase_order_queue = PurchaseOrderQueue.new(purchase_order_queue_params.merge(overseer: current_overseer))

    authorize @purchase_order_queue
    if @purchase_order_queue.save
      redirect_to overseers_purchase_order_queues_path, notice: flash_message(@purchase_order_queue, action_name)
    else
      render 'new'
    end
  end

  def edit
    authorize @purchase_order_queue
  end

  def update
    @purchase_order_queue.assign_attributes(purchase_order_queue_params.merge(overseer: current_overseer))
    authorize @purchase_order_queue
    if @purchase_order_queue.save_and_sync #@purchase_order_queue.product.approved? ? @purchase_order_queue.save_and_sync : @purchase_order_queue.save
      redirect_to overseers_purchase_order_queues_path, notice: flash_message(@purchase_order_queue, action_name)
    else
      render 'edit'
    end
  end

  private

  def purchase_order_queue_params
    params.require(:purchase_order_queue).permit(
        :inquiry_id,
        :sales_order_id,
        :status
    )
  end

  def set_purchase_order_queue
    @purchase_order_queue = purchase_order_queue.find(params[:id])
  end
end