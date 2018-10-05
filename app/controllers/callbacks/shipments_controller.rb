class Callbacks::ShipmentsController < Callbacks::BaseController

  #request params: {"store_id":null,"doc_entry":"9","total_weight":"0","total_qty":"1","email_sent":null,"order_id":"10210198","customer_id":null,"shipping_address_id":"5123","billing_address_id":"5123","shipment_status":null,"increment_id":"30210001","created_at":"2018-05-10","updated_at":"2018-05-10","packages":null,"shipping_label":null,"sup_status":null,"ship_follow_up_date":"2018-05-10","shp_pod":null,"shp_grn":null,"ship_delivery_date":"2018-05-10","ItemLine":[{"row_total":"21000","price":"21000","weight":"0","qty":"1","product_id":"757069","order_item_id":"","additional_data":null,"description":"AirExportFreightCharges","name":"JSCOGCCKazstroyService","sku":"BM9P2Y7"}],"TrackLine":[{"weight":"0","qty":"1","order_id":"10210198","track_number":"","description":null,"title":"","carrier_code":"","created_at":"2018-05-10","updated_at":"2018-05-10","expected_delivery_date":"2018-05-10","grn":null,"invoice_number":null,"order_created_at":"2018-05-10"}]}

  def create
    id = params['increment_id']
    created_at = params['created_at']
    order_number = params['order_id']

    sales_order = SalesOrder.find_by_order_number!(order_number)
    sales_shipment = sales_order.shipments.where(remote_uid: id).first_or_create! do |sales_shipment|
      sales_shipment.created_at = created_at.to_datetime
      sales_shipment.overseer = Overseer.default_approver
    end

    params['ItemLine'].each do |remote_row|
      sales_shipment.rows.where(sku: remote_row['sku']).first_or_create! do |row|
        row.update_attributes(
            :sku => remote_row['sku'],
            :qty => remote_row['']
        )
      end
    end

    render json: format_response(1, 'Shipment created successfully.', {}), status: :ok
  end

  def update
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
    render json: format_response(1, 'Shipment updated successfully.', {}), status: :ok

  end
end