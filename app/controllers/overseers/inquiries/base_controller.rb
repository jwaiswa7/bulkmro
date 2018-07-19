class Overseers::Inquiries::BaseController < Overseers::BaseController
  before_action :set_inquiry

  private
  def set_inquiry
    @inquiry = Inquiry.find(params[:inquiry_id])
  end
end
