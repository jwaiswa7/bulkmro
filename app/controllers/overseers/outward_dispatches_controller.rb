class Overseers::OutwardDispatchesController < Overseers::BaseController
  before_action :set_outward_dispatch, only: [:show, :edit, :update, :destroy, :render_modal_form, :add_comment, :make_packing_zip]

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

  def make_packing_zip
    authorize_acl @outward_dispatch
    @packing_slips = @outward_dispatch.packing_slips
    service = Services::Overseers::OutwardDispatches::Zipped.new(@packing_slips, locals)
    zip = service.call
    send_data(zip, type: 'application/zip', filename: @outward_dispatch.zipped_filename(include_extension: true))
  end

  # GET /outward_dispatches/new
  def new
    @sales_invoice = SalesInvoice.find(params[:sales_invoice_id])
    @sales_order = @sales_invoice.sales_order
    @outward_dispatch = OutwardDispatch.new(overseer: current_overseer, sales_order: @sales_order,
                                            sales_invoice: @sales_invoice)
    @packing_slips_row = @sales_invoice.rows.sum(&:get_remaining_quantity)
    @can_show_box = @packing_slips_row == 1
    if @can_show_box
      @outward_dispatch.packing_slips.build(overseer: current_overseer)
    end

    authorize_acl @outward_dispatch
  end

  # GET /outward_dispatches/1/edit
  def edit
    @packing_slips_row = @outward_dispatch.sales_invoice.rows.sum(&:get_remaining_quantity)
    @can_show_box = @packing_slips_row == 0 || @packing_slips_row == 1
    authorize_acl @outward_dispatch
  end

  # POST /outward_dispatches
  # POST /outward_dispatches.json
  def create
    @outward_dispatch = OutwardDispatch.new(outward_dispatch_params.merge(overseer: current_overseer))
    authorize_acl @outward_dispatch
    respond_to do |format|
      if @outward_dispatch.save
        if @outward_dispatch.packing_slips.present?
          url = add_packing_overseers_outward_dispatch_packing_slips_url (@outward_dispatch)
        else
          url = overseers_outward_dispatch_path(@outward_dispatch)
        end
        inward_dispatches = InwardDispatch.where(id: @outward_dispatch.sales_invoice.inward_dispatch_ids)
        inward_dispatches.map {|inward_dispatch| inward_dispatch.set_outward_status}
        format.html { redirect_to url, notice: 'Outward dispatch was successfully created.' }
        format.json { render :add_packing, status: :created, location: @outward_dispatch }
      else
        format.html { render :new }
        format.json { render json: @outward_dispatch.errors, status: :unprocessable_entity }
      end
    end
  end

  def create_with_packing_slip
    @sales_invoice = ArInvoiceRequest.find(params[:sales_invoice_id])
    @sales_order = @sales_invoice.sales_order
    @outward_dispatch = OutwardDispatch.new(overseer: current_overseer, sales_order: @sales_order,
                                            sales_invoice: @sales_invoice)
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
        inward_dispatches = InwardDispatch.where(id: @outward_dispatch.sales_invoice.inward_dispatch_ids)
        inward_dispatches.map {|inward_dispatch| inward_dispatch.set_outward_status}
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

  def render_modal_form
    authorize_acl @outward_dispatch
    respond_to do |format|
      if params[:title] == 'Comment'
        format.html {render partial: 'shared/layouts/add_comment', locals: {obj: @outward_dispatch, url: add_comment_overseers_outward_dispatch_path(@outward_dispatch), view_more: overseers_outward_dispatch_path(@outward_dispatch)}}
      end
    end
  end

  def add_comment
    @outward_dispatch.assign_attributes(outward_dispatch_params.merge(overseer: current_overseer))
    authorize_acl @outward_dispatch
    if @outward_dispatch.valid?
      if params['outward_dispatch']['comments_attributes']['0']['message'].present?
        ActiveRecord::Base.transaction do
          @outward_dispatch.save!
          @outward_dispatch_comment = OutwardDispatchComment.new(message: '', outward_dispatch: @outward_dispatch, overseer: current_overseer)
        end
        render json: {success: 1, message: 'Successfully updated '}, status: 200
      else
        render json: {error: {base: 'Field cannot be blank!'}}, status: 500
      end
    else
      render json: {error: @outward_dispatch.errors}, status: 500
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
        :sales_invoice_id,
        :sales_order_id,
        :material_dispatch_date,
        :expected_date_of_delivery,
        :material_delivery_date,
        :dispatched_by,
        :dispatch_mail_sent_to_the_customer,
        :logistics_partner,
        :logistics_partner_name,
        :tracking_number,
        :material_delivered_mail_sent_to_customer,
        packing_slips_attributes: [:id, :box_number, :outward_dispatch_id, :box_dimension, :created_by_id, :updated_by_id, :_destroy],
        comments_attributes: [:id, :message, :created_by_id, :updated_by_id]
    )
  end

    attr_accessor :locals
end
