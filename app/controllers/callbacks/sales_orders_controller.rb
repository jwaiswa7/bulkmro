class Callbacks::SalesOrdersController < Callbacks::BaseController
  protect_from_forgery with: :null_session
  before_action :authenticate_callback

  def create
    resp_status = 0
    resp_msg = 'Invalid request.'
    resp_response = ''
    #request params: {"U_MgntDocID":"942","Status":"1","comment":"","DocNum":"10300008","DocEntry":"609","UserEmail":"35","SapReject":""}
    #
    # '{"increment_id":"10211009","status":"1","comment":"","request_id":"3508","doc_entry":"5836","user_email":"120","sap_reject":""}'
    #In create U_MgntDocID is ref id vaule sent while creating sales draft from magento to SAP
    if params['U_MgntDocID'] && params['Status']
      if params['Status'] == '1'
        #create order from quotation and take actions like add products / billing-shpping address / tax etc, update so draft
        #in response send all order product details like below. ref: #'U_MgntDocID' => orderID,'ItemCode' => Sku,'OrderItemId' => itemId


        @sales_quote = SalesQuote.find_by_quotation_uid(params['DocEntry'])
        @sales_order = Services::Overseers::SalesOrders::BuildFromSalesQuote.new(@sales_quote, @sales_quote.overseer).call
        @sales_order.save
        resp_status = 1
        doc_id = @sales_order.order_number
        items = []
        @sales_order.rows.each do |row|
          item = OpenStruct.new({U_MgntDocID: doc_id, ItemCode: row.product.sku, OrderItemId: row.to_remote_s})
          items.push(item.marshal_dump)
        end

        resp_msg = "Order Created Successfully"
        resp_response = {
            U_MgntDocID: doc_id,
            DocumentLines: items
        }
      elsif params['Status'] == '2'
        #sap reject also add comment
        # UPDATE order_request_flow SET  request_status = 'SAP Rejected' , sap_reject = 1  WHERE order_request_id

        @sales_order

        InquiryComment.new()

        @sales_order.create_rejection(:comment => @comment, :overseer => current_overseer)

        resp_status = 1


        resp_msg = "SO Draft Rejected Successfully"
      elsif params['Status'] == '3'
        #UPDATE order_request_flow SET request_status = 'Hold by finance', sap_reject = 2 WHERE order_request_id
        #sap reject also add comment
        resp_status = 1
        resp_msg = "SO Draft Updated Successfully"
      else
        resp_msg = "Invalid/Unknown Status received from SAP.";
      end
    end

    response = format_response(resp_status, resp_msg, resp_response)
    render json: response, status: :ok
  end

  def update
    resp_status = 0
    resp_msg = 'Invalid request.'
    resp_response = ''
    #request params: {"increment_id":"2001656","sap_order_status":"30","comment":"","DocNum":"2001656","DocEntry":"2169","UserEmail":"35","SapReject":""}
    # In update increment_id and DocNum are same
    if params['increment_id'] && params['sap_order_status']
      #update order based on status (like cancel) and add comment
      if params['sap_order_status'] == '30'
        #cancel the order along with update quote product qty and cancel order item qty
        resp_status = 1


        resp_msg = "The order has been cancelled Successfully"
      else
        resp_status = 1
        resp_msg = "The order has been updated Successfully"
      end
    end
    response = format_response(resp_status, resp_msg)
    render json: response, status: :ok
  end
end