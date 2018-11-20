class Overseers::PurchaseOrderQueuesController < Overseers::BaseController
  before_action :set_purchase_order_queue, only: [:show, :edit, :update, :new_comment]

  def index
    @purchase_order_queues = ApplyDatatableParams.to(PurchaseOrderQueue.all.order('id DESC'), params)
    authorize @purchase_order_queues
  end

  def show
    authorize @purchase_order_queue
  end

  def new
    if params[:sales_order].present?
      @sales_order = SalesOrder.find(params[:sales_order])
      @purchase_order_queue = PurchaseOrderQueue.new(:overseer => current_overseer, :sales_order => @sales_order, :inquiry => @sales_order.inquiry)
      authorize @purchase_order_queue
    else
      redirect_to overseers_purchase_order_queues_path
    end
  end

  def new_comment
    if params[:purchase_order_queue][:message].present?
      @purchase_order_comment = PurchaseOrderComment.new(:message => params[:purchase_order_queue][:message], :purchase_order_queue => @purchase_order_queue, :overseer => current_overseer)
      authorize @purchase_order_comment
      if @purchase_order_comment.save
        redirect_to overseers_purchase_order_queues_path, notice: flash_message(@purchase_order_queue, action_name)
      else
        redirect_to overseers_purchase_order_queues_path, notice: flash_message(@purchase_order_queue, action_name)
      end
    else
      redirect_to overseers_purchase_order_queues_path, notice: flash_message(@purchase_order_queue, action_name)
    end
  end

  def create
    @purchase_order_queue = PurchaseOrderQueue.new(purchase_order_queue_params.merge(overseer: current_overseer))
    authorize @purchase_order_queue
    if @purchase_order_queue.save
      @purchase_order_comment = PurchaseOrderComment.new(:message => "PO Request submitted." , :purchase_order_queue => @purchase_order_queue, :overseer => current_overseer)
      @purchase_order_comment.save
      redirect_to overseers_purchase_order_queues_path, notice: flash_message(@purchase_order_queue, action_name)
    else
      render 'new'
    end
  end

  def edit
    authorize @purchase_order_queue
  end

  def update
    current_status = @purchase_order_queue.status
    @purchase_order_queue.assign_attributes(purchase_order_queue_params.merge(overseer: current_overseer))
    authorize @purchase_order_queue
    if @purchase_order_queue.save
      if current_status != @purchase_order_queue.status
        @purchase_order_comment = PurchaseOrderComment.new(:message => "Status Changed : " + @purchase_order_queue.status , :purchase_order_queue => @purchase_order_queue, :overseer => current_overseer)
        @purchase_order_comment.save
      end
      redirect_to overseers_purchase_order_queues_path, notice: flash_message(@purchase_order_queue, action_name)
    else
      redirect_to edit_overseers_purchase_order_queue_path, notice: flash_message(@purchase_order_queue, action_name)
    end
  end

  private

  def purchase_order_queue_params
    params.require(:purchase_order_queue).permit(
        :id,
        :inquiry_id,
        :sales_order_id,
        :purchase_order_number,
        :status
    )
  end

  def set_purchase_order_queue
    @purchase_order_queue = PurchaseOrderQueue.find(params[:id])
  end
end