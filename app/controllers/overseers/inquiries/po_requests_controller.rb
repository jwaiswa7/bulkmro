class Overseers::Inquiries::PoRequestsController < Overseers::Inquiries::BaseController
  before_action :set_po_request, only: [:show]

  def index
    @po_requests = @inquiry.po_requests
    authorize @po_requests
  end

  def show
    authorize @po_request


    respond_to do |format|
      format.html {}
      format.pdf do
        render_pdf_for @po_request
      end
    end
  end

  def new
    @po_requests = @inquiry.po_requests.build
    @po_request_rows = @po_requests.rows.build
    authorize @po_requests
  end

  private

  def set_po_request
    @po_request = @inquiry.po_requests.find(params[:id])
  end
end

