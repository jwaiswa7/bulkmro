json.data (@sales_orders) do |sales_order|
  json.array! [
                    [],
                    sales_order[:inquiry_number],
                    sales_order[:company],
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
                    sales_order[:inward_date].present? ? format_date_without_time(Date.parse(sales_order[:inward_date])) : '-'
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
                       []
                   ]


json.recordsTotal SalesOrder.all.count
json.recordsFiltered @indexed_sales_orders.count
json.draw params[:draw]
