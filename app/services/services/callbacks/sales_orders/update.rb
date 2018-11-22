class Services::Callbacks::SalesOrders::Update < Services::Callbacks::Shared::BaseCallback

  def initialize(params)
    @params = params
  end

  def call
    order_number = params['increment_id']
    remote_status = params['sap_order_status']

    if order_number && remote_status
      sales_order = SalesOrder.find_by_order_number!(order_number)

      if sales_order.present?
        ex_comment = InquiryComment.order(created_at: :desc).limit(1).find_by_sales_order_id_and_created_by_id(sales_order.id,Overseer.default_approver.id)
        ex_message = ex_comment.message if ex_comment.present?

        begin
          sales_order.update_attributes(:remote_status => remote_status.to_i)
          message = [
              ["SAP Status Updated: ", sales_order.remote_status].join
          ].join('\n')
          InquiryComment.create(message: message, inquiry: sales_order.inquiry, overseer: Overseer.default_approver , sales_order: sales_order) if sales_order.inquiry.present? && ex_message != message
          sales_order.update_index
          return_response("Order Updated Successfully")
        rescue => e
          return_response(e.message, 0)
        end
      else
        return_response("Order Number not found.", 0)
      end
    else
      return_response("Order Number or Status blank.", 0)
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