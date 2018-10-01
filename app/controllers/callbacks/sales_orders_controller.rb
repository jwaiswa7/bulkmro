class Callbacks::SalesOrdersController < Callbacks::BaseController
  protect_from_forgery with: :null_session
  before_action :authenticate_callback

  def create
    resp_status = 0
    resp_msg = 'Invalid request.'
    resp_response = ''

    request = log_request(:sync_back, params)

    #request params: {"U_MgntDocID":"942","Status":"1","comment":"","DocNum":"10300008","DocEntry":"609","UserEmail":"35","SapReject":""}
    #
    #In create U_MgntDocID is ref id vaule sent while creating sales draft from magento to SAP
    if params['U_MgntDocID'] && params['Status']

      sales_order = SalesOrder.find(params['U_MgntDocID']) || SalesOrder.find_by_legacy_id(params['U_MgntDocID'])

      if params['Status'] == '1'
        #create order from quotation and take actions like add products / billing-shpping address / tax etc, update so draft
        #in response send all order product details like below. ref: #'U_MgntDocID' => orderID,'ItemCode' => Sku,'OrderItemId' => itemId

        sales_order.order_number = params['DocNum']
        sales_order.doc_number = params['DocNum']
        sales_order.save

        resp_msg = "Order Created Successfully"
        items = []

        sales_order.rows.each do |row|
          item = OpenStruct.new({U_MgntDocID: sales_order.order_number, ItemCode: row.sales_quote_row.product.sku, OrderItemId: row.to_remote_s})
          items.push(item.marshal_dump)
        end

        sales_order.save

        resp_response = {
            U_MgntDocID: sales_order.order_number,
            DocumentLines: items
        }

      elsif params['Status'] == '2'
        #sap reject also add comment
        # UPDATE order_request_flow SET  request_status = 'SAP Rejected' , sap_reject = 1  WHERE order_request_id

        comment = InquiryComment.create(message: params['comment'], inquiry: sales_order.inquiry)
        sales_order.create_rejection(:comment => comment, :overseer => sales_order.overseer)

        resp_status = 1
        resp_msg = "SO Draft Rejected Successfully"

      elsif params['Status'] == '3'
        #UPDATE order_request_flow SET request_status = 'Hold by finance', sap_reject = 2 WHERE order_request_id
        #sap reject also add comment
        resp_status = 1
        #TODO
        InquiryComment.create(message: params['comment'], inquiry: sales_order.inquiry)

        resp_msg = "SO Draft Updated Successfully"
      else
        resp_msg = "Invalid/Unknown Status received from SAP.";
      end


    end

    response = format_response(resp_status, resp_msg, resp_response)
    request.response_message = response.to_json
    request.status = :success
    request.save

    render json: response, status: :ok
  end

  def update
    resp_status = 0
    resp_msg = 'Invalid request.'
    resp_response = ''


    request = log_request(:sync_back, params)
    #request params: {"increment_id":"2001656","sap_order_status":"30","comment":"","DocNum":"2001656","DocEntry":"2169","UserEmail":"35","SapReject":""}
    # In update increment_id and DocNum are same
    if params['increment_id'] && params['sap_order_status']
      #update order based on status (like cancel) and add comment
      sales_order = SalesOrder.find_by_order_number(params['increment_id'])
      resp_status = 1
      comment = ""

      if !params['comment'].blank?
        comment = params['comment']
      end

      if !params['sap_order_status'].blank? || !comment.blank?
        #cancel the order along with update quote product qty and cancel order item qty
        sales_order.remote_status = params['sap_order_status']
        #sales_order.remote_status = "SAP Approved"
        sales_order.save

        if comment.blank?
          comment = ["SAP Status Updated: ", sales_order.remote_status].join
        end
        InquiryComment.create(message: params['comment'], inquiry: sales_order.inquiry, overseer: sales_order.overseer)
        resp_msg = "Order Updated Successfully"
      else

        resp_msg = "Nothing to Update"
      end

    end
    response = format_response(resp_status, resp_msg)
    request.response_message = response.to_json
    request.status = :success
    request.save

    render json: response, status: :ok
  end
end