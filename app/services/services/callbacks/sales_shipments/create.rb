class Services::Callbacks::SalesShipments::Create < Services::Callbacks::Shared::BaseCallback

  def initialize(params)
    @params = params
  end

  def call
    shipment_number = params['increment_id']
    created_at = params['created_at'].to_datetime
    order_number = params['order_id']
    remote_rows = params['ItemLine']
    remote_packages = params['TrackLine']

    sales_order = SalesOrder.find_by_order_number!(order_number)
    sales_shipment = sales_order.shipments.where(shipment_number: shipment_number).first_or_create! do |sales_shipment|
      sales_shipment.created_at = created_at
      sales_shipment.overseer = Overseer.default_approver
    end

    remote_rows.each do |remote_row|
      sku = remote_row['sku']

      sales_shipment.rows.where(sku: sku).first_or_create! do |row|
        row.assign_attributes(
            :quantity => remote_row['qty'],
            :metadata => remote_row
        )
      end
    end

    remote_packages.each do |remote_package|
      tracking_number = remote_package['track_number']
      invoice_number = remote_package['invoice_number']
      sales_invoice = SalesInvoice.find_by_invoice_number(invoice_number)

      sales_shipment.packages.where(tracking_number: tracking_number).first_or_create! do |package|
        package.assign_attributes(
            :metadata => remote_package,
            :sales_invoice => sales_invoice
        )
      end
    end

    sales_shipment
  end

  attr_accessor :params
end

# {
#     "store_id": null,
#     "doc_entry": "9",
#     "total_weight": "0",
#     "total_qty": "1",
#     "email_sent": null,
#     "order_id": "10210198",
#     "customer_id": null,
#     "shipping_address_id": "5123",
#     "billing_address_id": "5123",
#     "shipment_status": null,
#     "increment_id": "30210001",
#     "created_at": "2018-05-10",
#     "updated_at": "2018-05-10",
#     "packages": null,
#     "shipping_label": null,
#     "sup_status": null,
#     "ship_follow_up_date": "2018-05-10",
#     "shp_pod": null,
#     "shp_grn": null,
#     "ship_delivery_date": "2018-05-10",
#     "ItemLine": [
#         {
#             "row_total": "21000",
#             "price": "21000",
#             "weight": "0",
#             "qty": "1",
#             "product_id": "757069",
#             "order_item_id": "",
#             "additional_data": null,
#             "description": "AirExportFreightCharges",
#             "name": "JSCOGCCKazstroyService",
#             "sku": "BM9P2Y7"
#         }
#     ],
#     "TrackLine": [
#         {
#             "weight": "0",
#             "qty": "1",
#             "order_id": "10210198",
#             "track_number": "",
#             "description": null,
#             "title": "",
#             "carrier_code": "",
#             "created_at": "2018-05-10",
#             "updated_at": "2018-05-10",
#             "expected_delivery_date": "2018-05-10",
#             "grn": null,
#             "invoice_number": null,
#             "order_created_at": "2018-05-10"
#         }
#     ]
# }
#