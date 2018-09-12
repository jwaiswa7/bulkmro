class Callbacks::SalesOrdersController < Callbacks::BaseController
  protect_from_forgery with: :null_session
  before_action :authenticate_callback
  def update
    #request params: {"increment_id":"2001656","sap_order_status":"30","comment":"","DocNum":"2001656","DocEntry":"2169","UserEmail":"35","SapReject":""}
    if params['increment_id'] && params['sap_order_status'] && params['comment']
      #update order based on status (like cancel) and add comment
      response['success'] = 1
      response['status'] = 1
      response['message'] = "The order has been updated Successfully"
    else
      response['success'] = 0
      response['status'] = 0
      response['message'] = "Invalid request."
    end
    render json: response, status: :ok
  end
  def create
    #request params: {"U_MgntDocID":"942","Status":"1","comment":"","DocNum":"10300008","DocEntry":"609","UserEmail":"35","SapReject":""}
    if params['U_MgntDocID'] && params['Status']
      #create order and take actions as per status, add products, update so draft
      # in response send all product details like 'U_MgntDocID' => order id(increment id) 'ItemCode' =>Sku ()'OrderItemId' => id of item in order
        response['success'] = 1
        response['status'] = 1
        response['message'] = "Order created Successfully"
        response['response'] = '{"DocumentLines":[{"U_MgntDocID":"10210751","ItemCode":"BM9L5G9","OrderItemId":"72713"},{"U_MgntDocID":"10210751","ItemCode":"BM9P7R8","OrderItemId":"72714"}],"U_MgntDocID":"10210751"}'
        # if sap reject true explicitly reject SO draft
        if params['SapReject'] == 1
          #reject SO Draft of order
          response['success'] = 1
          response['status'] = 1
          response['message'] = "SO Draft Rejected Successfully"
        end
    else
      response['success'] = 0
      response['status'] = 0
      response['message'] = "Invalid request."
    end
    render json: response, status: :ok
  end
end