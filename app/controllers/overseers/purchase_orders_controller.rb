# frozen_string_literal: true

class Overseers::PurchaseOrdersController < Overseers::BaseController
  before_action :set_purchase_order, only: [:edit_internal_status, :update_internal_status]

  def index
    authorize :purchase_order

    respond_to do |format|
      format.html { }
      format.json do
        service = Services::Overseers::Finders::PurchaseOrders.new(params, current_overseer)
        service.call

        @indexed_purchase_orders = service.indexed_records
        @purchase_orders = service.records.try(:reverse)

        status_service = Services::Overseers::Statuses::GetSummaryStatusBuckets.new(@indexed_purchase_orders, PurchaseOrder)
        status_service.call

        @total_values = status_service.indexed_total_values
        @statuses = status_service.indexed_statuses
      end
    end
  end

  def material_readiness_queue
    authorize :purchase_order
    @purchase_orders = ApplyDatatableParams.to(PurchaseOrder.material_readiness_queue, params)
    render 'material_readiness_queue'
  end

  def material_pickup_queue
    authorize :purchase_order
    @purchase_orders = ApplyDatatableParams.to(PurchaseOrder.material_pickup_queue, params)
    render 'material_readiness_queue'
  end

  def material_delivered_queue
    authorize :purchase_order
    @purchase_orders = ApplyDatatableParams.to(PurchaseOrder.material_delivered_queue, params)
    render 'material_readiness_queue'
  end

  def edit_internal_status
    authorize @purchase_order
  end

  def update_internal_status
    authorize @purchase_order
    @purchase_order.assign_attributes(purchase_order_params)

    if @purchase_order.valid?
      ActiveRecord::Base.transaction do if @purchase_order.internal_status_changed?
                                          @po_comment = PoComment.new(message: "Status Changed: #{@purchase_order.internal_status}", purchase_order: @purchase_order, overseer: current_overseer)
                                          @purchase_order.save!
                                          @po_comment.save!
                                        else
                                          @purchase_order.save!
                                        end
      end
      redirect_to edit_internal_status_overseers_purchase_order_path, notice: flash_message(@purchase_order, action_name)
    else
      render 'edit_internal_status'
    end
  end

  def autocomplete
    if params[:inquiry_number].present?
      @purchase_orders = ApplyParams.to(PurchaseOrder.joins(:inquiry).where(inquiries: { inquiry_number: params[:inquiry_number] }), params)
    else
      @purchase_orders = ApplyParams.to(PurchaseOrder.all, params)
    end

    authorize :purchase_order
  end

  def export_all
    authorize :purchase_order
    service = Services::Overseers::Exporters::PurchaseOrdersExporter.new
    service.call

    redirect_to url_for(Export.purchase_orders.last.report)
  end

  private

    def set_purchase_order
      @purchase_order = PurchaseOrder.find(params[:id])
    end

    def purchase_order_params
      params.require(:purchase_order).permit(
        :internal_status,
          comments_attributes: [:id, :message, :created_by_id],
          attachments: []
      )
    end
end
