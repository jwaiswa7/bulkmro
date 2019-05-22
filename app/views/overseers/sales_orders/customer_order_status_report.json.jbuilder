json.data (@customer_order_status_records) do |sales_order|
  json.array! [
                  [],
                  sales_order[:inquiry_number],
                  sales_order[:company],
                  sales_order[:account],
                  sales_order[:order_number].present? ? sales_order[:order_number] : '-',
                  sales_order[:mis_date].present? ? format_date_without_time(Date.parse(sales_order[:mis_date])) : '-',
                  sales_order[:cp_committed_date].present? ? format_date_without_time(Date.parse(sales_order[:cp_committed_date])) : '-',
                  sales_order[:po_number].present? ? sales_order[:po_number] : '-',
                  sales_order[:supplier_name].present? ? sales_order[:supplier_name] : '-',
                  sales_order[:supplier_po_request_date].present? ? format_date_without_time(Date.parse(sales_order[:supplier_po_request_date])) : '-',
                  sales_order[:supplier_po_date].present? ? format_date_without_time(Date.parse(sales_order[:supplier_po_date])) : '-',
                  sales_order[:po_email_sent].present? ? format_date_without_time(Date.parse(sales_order[:po_email_sent])) : '-',
                  sales_order[:payment_request_date].present? ? format_date_without_time(Date.parse(sales_order[:payment_request_date])) : '-',
                  sales_order[:payment_date].present? ? format_date_without_time(Date.parse(sales_order[:payment_date])) : '-',
                  sales_order[:cp_committed_date].present? ? format_date_without_time(Date.parse(sales_order[:cp_committed_date])) : '-',
                  sales_order[:actual_material_readiness_date].present? ? format_date_without_time(Date.parse(sales_order[:actual_material_readiness_date])) : '-',
                  sales_order[:pickup_date].present? ? format_date_without_time(Date.parse(sales_order[:pickup_date])) : '-',
                  sales_order[:inward_date].present? ? format_date_without_time(Date.parse(sales_order[:inward_date])) : '-',
                  sales_order[:outward_date].present? ? format_date_without_time(Date.parse(sales_order[:outward_date])) : '-',
                  sales_order[:customer_delivery_date].present? ? format_date_without_time(Date.parse(sales_order[:customer_delivery_date])) : '-',
                  sales_order[:on_time_or_delayed_time].present? ? humanize(sales_order[:on_time_or_delayed_time]) : '-',
              ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       []
                   ]


json.recordsTotal @sales_orders.count
json.recordsFiltered @sales_orders.count
json.draw params[:draw]
