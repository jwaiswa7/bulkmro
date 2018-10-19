class Customers::InquiriesController < Customers::BaseController

  before_action :get_contact

  def index
    respond_to do |format|
      format.html {}
      format.json do
        @inquiries = ApplyDatatableParams.to(@contact.inquiries, params)
      end
    end
  end

  def show
    @inquiry = Inquiry.find(params[:id])
    @inquiries_count = @contact.inquiries.count
  end

  private

  def get_contact
    @contact = current_contact
  end
end