class Overseers::InquiriesController < Overseers::BaseController
  def index
    @inquiries = ApplyDatatableParams.to(Inquiry.all, params)
    authorize @inquiries
  end
end
