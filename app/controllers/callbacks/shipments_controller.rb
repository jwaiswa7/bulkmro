class Callbacks::ShipmentsController < Callbacks::BaseController
  protect_from_forgery with: :null_session
  before_action :authenticate_callback

  def create
    resp_status = 0
    resp_msg = 'Invalid request.'
    resp_response = ''
    #request params: {"store_id":null,"doc_entry":"9","total_weight":"0","total_qty":"1","email_sent":null,"order_id":"10210198","customer_id":null,"shipping_address_id":"5123","billing_address_id":"5123","shipment_status":null,"increment_id":"30210001","created_at":"2018-05-10","updated_at":"2018-05-10","packages":null,"shipping_label":null,"sup_status":null,"ship_follow_up_date":"2018-05-10","shp_pod":null,"shp_grn":null,"ship_delivery_date":"2018-05-10","ItemLine":[{"row_total":"21000","price":"21000","weight":"0","qty":"1","product_id":"757069","order_item_id":"","additional_data":null,"description":"AirExportFreightCharges","name":"JSCOGCCKazstroyService","sku":"BM9P2Y7"}],"TrackLine":[{"weight":"0","qty":"1","order_id":"10210198","track_number":"","description":null,"title":"","carrier_code":"","created_at":"2018-05-10","updated_at":"2018-05-10","expected_delivery_date":"2018-05-10","grn":null,"invoice_number":null,"order_created_at":"2018-05-10"}]}
    #In create U_MgntDocID is ref id vaule sent while creating sales draft from magento to SAP
    if params['increment_id'] && params['created_at'] && params['order_id']
      #delete existing shipment
      # create new shipment: add order details to shipment, add products from ItemLine, add tracking details from TrackLine, updating qty in sales order
      resp_status = 1
      resp_msg = "Shipment created successfully."
    end
    response = format_response(resp_status, resp_msg, resp_response)
    render json: response, status: :ok
  end

  def update
    resp_status = 0
    resp_msg = 'Invalid request.'
    #request params: {"increment_id":"30210923","state":"","comment":"BasedOnSalesQuotations2242.BasedOnSalesOrders10210825.","ship_follow_up_date":"1899-12-30","ship_delivery_date":"2018-08-30","shp_grn":"","pick_pack_remartk":""}
    # In update increment_id and DocNum are same
    if params['increment_id']
      #update shipment data as per request like add comment, remarks, dates
      if params['state'] == '3'
        #cancel the order along with reverse shipment item qty and cancel order item qty
        resp_status = 1
        resp_msg = "Shipment Canceled successfully"
      else
        resp_status = 1
        resp_msg = "Shipment updated successfully"
      end
    end
    response = format_response(resp_status, resp_msg)
    render json: response, status: :ok
  end
end