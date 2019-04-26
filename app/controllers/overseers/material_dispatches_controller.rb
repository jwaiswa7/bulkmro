class Overseers::MaterialDispatchesController < Overseers::BaseController
  before_action :set_material_dispatch, only: [:show, :edit, :update, :destroy]

  # GET /material_dispatches
  # GET /material_dispatches.json
  def index
    @material_dispatches = MaterialDispatch.all
  end

  # GET /material_dispatches/1
  # GET /material_dispatches/1.json
  def show
  end

  # GET /material_dispatches/new
  def new
    @material_dispatch = MaterialDispatch.new
  end

  # GET /material_dispatches/1/edit
  def edit
  end

  # POST /material_dispatches
  # POST /material_dispatches.json
  def create
    @material_dispatch = MaterialDispatch.new(material_dispatch_params)

    respond_to do |format|
      if @material_dispatch.save
        format.html { redirect_to @material_dispatch, notice: 'Material dispatch was successfully created.' }
        format.json { render :show, status: :created, location: @material_dispatch }
      else
        format.html { render :new }
        format.json { render json: @material_dispatch.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /material_dispatches/1
  # PATCH/PUT /material_dispatches/1.json
  def update
    respond_to do |format|
      if @material_dispatch.update(material_dispatch_params)
        format.html { redirect_to @material_dispatch, notice: 'Material dispatch was successfully updated.' }
        format.json { render :show, status: :ok, location: @material_dispatch }
      else
        format.html { render :edit }
        format.json { render json: @material_dispatch.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /material_dispatches/1
  # DELETE /material_dispatches/1.json
  def destroy
    @material_dispatch.destroy
    respond_to do |format|
      format.html { redirect_to material_dispatches_url, notice: 'Material dispatch was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_material_dispatch
      @material_dispatch = MaterialDispatch.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def material_dispatch_params
      params.fetch(:material_dispatch, {})
    end
end
