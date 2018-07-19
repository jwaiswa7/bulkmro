class Overseers::InquiriesController < Overseers::BaseController
  def index
    @inquiries = Inquiry.all
    authorize @inquiries
  end
end
