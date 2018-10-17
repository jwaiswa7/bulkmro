class Services::Callbacks::SalesOrders::Update < Services::Callbacks::Shared::BaseCallback

  def initialize(params)
    @params = params
  end

  def call
    order_number = params['increment_id']
    remote_status = params['sap_order_status']
    new_remote_status = SalesOrder.remote_statuses[remote_status]


    if order_number && remote_status
      sales_order = SalesOrder.find_by_order_number!(order_number)
      message = [
          ["SAP Status Updated: ", sales_order.remote_status].join
      ].join('\n')
      # if remote_status == 30
      #   comment = InquiryComment.create(message: message, inquiry: sales_order.inquiry, overseer: Overseer.default_approver)
      #   sales_order.create_rejection!(:comment => comment, :overseer => Overseer.default_approver)
      #   sales_order.approval.destroy!
      # elsif new_remote_status != sales_order.remote_status
      #   sales_order.update_attributes(:remote_status => new_remote_status)
      #   InquiryComment.create(message: message, inquiry: sales_order.inquiry, overseer: Overseer.default_approver)
      # end

      begin
        sales_order.update_attributes(:remote_status => new_remote_status)
        InquiryComment.create(message: message, inquiry: sales_order.inquiry, overseer: Overseer.default_approver)
        set_response("Order Updated Successfully")
      rescue => e
        set_response(e.message, 0)
      end
    else
      set_response("Order Number or Status blank.", 0)
    end
  end

  attr_accessor :params
end

# {
#     "U_MgntDocID":"942",
#     "Status":"1",
#     "comment":"",
#     "DocNum":"10300008",
#     "DocEntry":"609",
#     "UserEmail":"35",
#     "SapReject":""
# }

# {
#     "increment_id":"2001656",
#     "sap_order_status":"30",
#     "comment":"",
#     "DocNum":"2001656",
#     "DocEntry":"2169",
#     "UserEmail":"35",
#     "SapReject":""
# }