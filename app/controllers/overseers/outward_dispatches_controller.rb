class Overseers::OutwardDispatchesController < Overseers::BaseController
  before_action :set_outward_dispatch, only: [:show, :edit, :update, :destroy]

  # GET /outward_dispatches
  # GET /outward_dispatches.json
  def index
    authorize_acl :outward_dispatch
    if params[:status].present?
      base_filter = {
          base_filter_key: 'status',

          base_filter_value: OutwardDispatch.statuses[params[:status]]
      }
    end
    service = Services::Overseers::Finders::OutwardDispatches.new(params.merge(base_filter), current_overseer)
    service.call

    @indexed_outward_dispatches = service.indexed_records
    @outward_dispatches = service.records

    respond_to do |format|
      format.json { render 'index' }
      format.html { render 'index' }
    end
  end

  # GET /outward_dispatches/1
  # GET /outward_dispatches/1.json
  def show
    authorize_acl @outward_dispatch
  end

  # GET /outward_dispatches/new
  def new
    @ar_invoice = ArInvoiceRequest.find(params[:ar_invoice_request_id])
    @sales_order = @ar_invoice.sales_order
    @outward_dispatch = OutwardDispatch.new(overseer: current_overseer, sales_order: @sales_order, ar_invoice_request: @ar_invoice)

    authorize_acl @outward_dispatch
  end

  # GET /outward_dispatches/1/edit
  def edit
    authorize_acl @outward_dispatch
  end

  # POST /outward_dispatches
  # POST /outward_dispatches.json
  def create
    @outward_dispatch = OutwardDispatch.new(outward_dispatch_params.merge(overseer: current_overseer))
    authorize_acl @outward_dispatch

    respond_to do |format|
      if @outward_dispatch.save
        @outward_dispatch.ar_invoice_request.inward_dispatches.map{|inward_dispatch| inward_dispatch.set_outward_status}
        format.html { redirect_to overseers_outward_dispatch_path (@outward_dispatch), notice: 'Outward dispatch was successfully created.' }
        format.json { render :show, status: :created, location: @outward_dispatch }
      else
        format.html { render :new }
        format.json { render json: @outward_dispatch.errors, status: :unprocessable_entity }
      end
    end
  end

  def create_with_packing_slip
    @ar_invoice = ArInvoiceRequest.find(params[:ar_invoice_request_id])
    @sales_order = @ar_invoice.sales_order
    @outward_dispatch = OutwardDispatch.new(overseer: current_overseer, sales_order: @sales_order, ar_invoice_request: @ar_invoice)
    authorize_acl @outward_dispatch

    respond_to do |format|
      if @outward_dispatch.save
        format.html { redirect_to new_overseers_outward_dispatch_packing_slip_url (@outward_dispatch), notice: 'Outward dispatch was successfully created.' }
        format.json { render :show, status: :created, location: @outward_dispatch }
      else
        format.html { render :new }
        format.json { render json: @outward_dispatch.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /outward_dispatches/1
  # PATCH/PUT /outward_dispatches/1.json
  def update
    authorize_acl @outward_dispatch
    respond_to do |format|
      if @outward_dispatch.update(outward_dispatch_params.merge(overseer: current_overseer))
        @outward_dispatch.ar_invoice_request.inward_dispatches.map{|inward_dispatch| inward_dispatch.set_outward_status}
        format.html { redirect_to overseers_outward_dispatch_path (@outward_dispatch), notice: 'Outward dispatch was successfully updated.' }
        format.json { render :show, status: :ok, location: @outward_dispatch }
      else
        format.html { render :edit }
        format.json { render json: @outward_dispatch.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /outward_dispatches/1
  # DELETE /outward_dispatches/1.json
  def destroy
    authorize_acl @outward_dispatch
    @outward_dispatch.destroy
    respond_to do |format|
      format.html { redirect_to outward_dispatches_url, notice: 'Outward dispatch was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_outward_dispatch
      @outward_dispatch = OutwardDispatch.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def outward_dispatch_params
      params.require(:outward_dispatch).except(:action_name).permit(
        :ar_invoice_request_id,
        :sales_order_id,
        :material_dispatch_date,
        :expected_date_of_delivery,
        :material_delivery_date,
        :dispatched_by,
        :dispatch_mail_sent_to_the_customer,
        :logistics_partner,
        :tracking_number,
        :material_delivered_mail_sent_to_customer
      )
    end
end
