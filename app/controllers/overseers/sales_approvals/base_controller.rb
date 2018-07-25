class Overseers::SalesApprovals::BaseController < Overseers::BaseController
  before_action :set_sales_approval

  private
  def set_sales_approval
    @sales_approval = SalesApproval.find(params[:sales_approval_id])
    @inquiry = @sales_approval.inquiry
  end
end
