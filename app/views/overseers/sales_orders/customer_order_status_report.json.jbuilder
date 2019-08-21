json.data (@customer_order_status_records) do |sales_order|
  columns = [
                  [],
                  sales_order[:inquiry_number],
                  sales_order[:company],
                  sales_order[:account],
                  sales_order[:order_number].present? ? sales_order[:order_number] : '-',
                  if params['customer_order_status_report'].present? && params['customer_order_status_report']['category'] == 'By BM'
                    sales_order[:invoice_number].present? ? sales_order[:invoice_number] : '-'
                  else
                    ''
                  end,
                  if params['customer_order_status_report'].present? && params['customer_order_status_report']['category'] == 'By BM'
                    sales_order[:sku].present? ? sales_order[:sku] : '-'
                  else
                    ''
                  end,
                  sales_order[:mis_date].present? ? format_date_without_time(Date.parse(sales_order[:mis_date])) : '-',
                  sales_order[:cp_committed_date].present? ? format_date_without_time(Date.parse(sales_order[:cp_committed_date])) : '-',
                  sales_order[:po_number].present? ? sales_order[:po_number] : '-',
                  sales_order[:supplier_name].present? ? sales_order[:supplier_name] : '-',
                  sales_order[:supplier_po_request_date].present? ? format_date_without_time(Date.parse(sales_order[:supplier_po_request_date])) : '-',
                  sales_order[:supplier_po_date].present? ? format_date_without_time(Date.parse(sales_order[:supplier_po_date])) : '-',
                  sales_order[:po_email_sent].present? ? format_date_without_time(Date.parse(sales_order[:po_email_sent])) : '-',
                  # sales_order[:payment_request_date].present? ? format_date_without_time(Date.parse(sales_order[:payment_request_date])) : '-',
                  # sales_order[:payment_date].present? ? format_date_without_time(Date.parse(sales_order[:payment_date])) : '-',
                  sales_order[:cp_committed_date].present? ? format_date_without_time(Date.parse(sales_order[:cp_committed_date])) : '-',
                  sales_order[:actual_material_readiness_date].present? ? format_date_without_time(Date.parse(sales_order[:actual_material_readiness_date])) : '-',
                  sales_order[:pickup_date].present? ? format_date_without_time(Date.parse(sales_order[:pickup_date])) : '-',
                  sales_order[:inward_date].present? ? format_date_without_time(Date.parse(sales_order[:inward_date])) : '-',
                  sales_order[:outward_date].present? ? format_date_without_time(Date.parse(sales_order[:outward_date])) : '-',
                  sales_order[:customer_delivery_date].present? ? format_date_without_time(Date.parse(sales_order[:customer_delivery_date])) : '-',
                  (sales_order[:on_time_or_delayed_time].present? ? sales_order[:on_time_or_delayed_time] == 0 ? 'On Time' : humanize(sales_order[:on_time_or_delayed_time]) : (sales_order[:customer_delivery_date] == sales_order[:cp_committed_date] ? 'On Time' : '-'))
              ]
  columns = Hash[columns.collect.with_index { |item, index| [index, item] }]
  if (sales_order[:cp_committed_date].present? && sales_order[:delivery_status] == 'Not Delivered') && sales_order[:cp_committed_date].to_date <= (Date.today + 3.day)
    if sales_order[:cp_committed_date].to_date >= Date.today && (sales_order[:cp_committed_date].to_date <= (Date.today + 2.day)) && !sales_order[:customer_delivery_date].present?
      class_name='bg-highlight-color-yellow'
    elsif sales_order[:cp_committed_date].to_date >= Date.today && (sales_order[:cp_committed_date].to_date <= (Date.today + 2.day)) && sales_order[:customer_delivery_date].present?
      class_name=''
    else
      class_name='bg-highlight-danger'
    end
  else
    class_name=''
  end
  json.merge! columns.merge("DT_RowClass": class_name)
end

json.columnFilters [
                       [],
                       [],
                       [{ "source": autocomplete_overseers_companies_path }],
                       [{ "source": autocomplete_overseers_accounts_path }],
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
                       # [],
                       # [],
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
