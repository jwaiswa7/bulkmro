class Services::Overseers::Callbacks::UpdateShipmentStatus < Services::Shared::BaseService

  def initialize(params)
    @params = params
  end

  def call



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

  end

  attr_accessor :params
end

# {
#     "increment_id": "30210923",
#     "state": "",
#     "comment": "BasedOnSalesQuotations2242.BasedOnSalesOrders10210825.",
#     "ship_follow_up_date": "1899-12-30",
#     "ship_delivery_date": "2018-08-30",
#     "shp_grn": "",
#     "pick_pack_remark": ""
# }