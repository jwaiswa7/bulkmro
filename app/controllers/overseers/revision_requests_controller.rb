class Overseers::RevisionRequestsController < Overseers::BaseController
  before_action :set_inquiry


  def index
    @revision_requests = @inquiry.revision_requests.includes(:contact, :sales_quote)
  end



    private

      def set_inquiry
        @inquiry = Inquiry.find(params[:inquiry_id])
      end
end
