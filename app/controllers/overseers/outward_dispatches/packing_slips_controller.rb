class Overseers::OutwardDispatches::PackingSlipsController < Overseers::BaseController
  before_action :set_packing_slip, only: [:show, :edit, :update, :destroy]
  before_action :set_outward_dispatch, only: [:new, :create, :update, :show, :edit]


  # GET /packing_slips
  # GET /packing_slips.json
  def index
    authorize :packing_slip
    @packing_slips = PackingSlip.all
  end

  # GET /packing_slips/1
  # GET /packing_slips/1.json
  def show
    authorize @packing_slip
  end

  # GET /packing_slips/new
  def new
    @packing_slip = PackingSlip.new(overseer: current_overseer, outward_dispatch: @outward_dispatch)
    @packing_slip.outward_dispatch.ar_invoice_request.rows.each do |row|
      if row.get_remaining_quantity > 0
        @packing_slip.rows.build(delivery_quantity: row.get_remaining_quantity, ar_invoice_request_row: row,ar_invoice_request_row_id: row.id)
      end
    end
    authorize @packing_slip
  end

  # GET /packing_slips/1/edit
  def edit
    authorize @packing_slip
  end

  # POST /packing_slips
  # POST /packing_slips.json
  def create
    @packing_slip = @outward_dispatch.packing_slips.new()
    @packing_slip.assign_attributes(packing_slip_params.merge(overseer: current_overseer))
    authorize @packing_slip
    respond_to do |format|
      if @packing_slip.save
        format.html { redirect_to overseers_outward_dispatch_packing_slip_path(@outward_dispatch, @packing_slip), notice: 'Packing Slip was successfully created.' }
        format.json { render :show, status: :created, location: @packing_slip }
      else
        format.html { render :new }
        format.json { render json: @packing_slip.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /packing_slips/1
  # PATCH/PUT /packing_slips/1.json
  def update
    authorize @packing_slip
    respond_to do |format|
      if @packing_slip.update(packing_slip_params.merge(overseer: current_overseer))
        format.html {redirect_to overseers_outward_dispatch_packing_slip_path(@outward_dispatch,@packing_slip), notice: 'Packing Slip was successfully updated.'}
        format.json {render :show, status: :ok, location: @packing_slip}
      else
        format.html {render :edit}
        format.json {render json: @packing_slip.errors, status: :unprocessable_entity}
        format.json {render json: @packing_slip.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /packing_slips/1
  # DELETE /packing_slips/1.json
  def destroy
    authorize @packing_slip
    @packing_slip.destroy
    respond_to do |format|
      format.html {redirect_to packing_slips_url, notice: 'Packing Slip was successfully destroyed.'}
      format.json {head :no_content}
    end
  end

  private

  def set_outward_dispatch
    @outward_dispatch = OutwardDispatch.find(params[:outward_dispatch_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_packing_slip
    @packing_slip = PackingSlip.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def packing_slip_params
    params.require(:packing_slip).except(:action_name).permit(
        :id,
        :outward_dispatch_id,
        :box_number,
        :box_detail,
        rows_attributes: [:id, :ar_invoice_request_row_id, :delivery_quantity, :packing_slip_id, :_destroy]
    )
  end
end
