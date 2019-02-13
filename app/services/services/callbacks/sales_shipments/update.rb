

class Services::Callbacks::SalesShipments::Update < Services::Callbacks::Shared::BaseCallback
  def call
    begin
      shipment = SalesShipment.find_by_shipment_number(params["increment_id"])

      if shipment.present?
        message = params["comment"]

        shipment.update_attributes!(
          status: params["state"].blank? ? nil : to_local_status(params["state"].to_i),
          delivery_date: params["ship_delivery_date"],
          followup_date: params["ship_follow_up_date"],
          shipment_grn: params["shp_grn"],
          metadata: (shipment.metadata.present? ? shipment.metadata.merge!(params) : params),
          packing_remarks: params["pick_pack_remark"]
        )

        shipment.comments.create!(message: message, metadata: params)
        return_response("Sales Shipment updated successfully.")
      else
        return_response("Sales Shipment not found.", 0)
      end
    rescue => e
      return_response(e.message, 0)
    end
  end

  def to_local_status(remote_status)
    case remote_status
    when 3
      :cancelled
    else
      :default
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
