class Services::Overseers::Callbacks::Shipments::UpdateStatus < Services::Shared::BaseService

  def initialize(params)
    @params = params
  end

  def call
    remote_uid = params['increment_id']
    remote_status = params['state']
    sales_order = SalesOrder.find_by_remote_uid(remote_uid)
    shipment = sales_order.shipment
    message = params['comment']

    ActiveRecord::Base.transaction do
      shipment.update_attributes!(:status => to_local_status(remote_status))
      shipment.comments.create!({
                                    :message => message,
                                    :metadata => params,
                                    :overseer => Overseer.default_approver
                                })

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