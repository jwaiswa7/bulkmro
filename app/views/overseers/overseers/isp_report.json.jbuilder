json.data (@records) do |record|
  json.array! [
                  record[:name],
                  link_to(record[:inquiries_count], filtered_path(overseers_inquiries_path, [filter_by_value('Inside Sales', nil, record[:id]), filter_by_date_range('Date', @date_range)]), target: '_blank'),
                  record[:sales_quotes_count],
                  link_to(record[:sales_orders_count], filtered_path(overseers_sales_orders_path, [filter_by_value('Inside Sales', nil, record[:id]), filter_by_date_range('Order Date', @date_range)]), target: '_blank'),
                  link_to(record[:purchase_orders_count], filtered_path(overseers_purchase_orders_path, [filter_by_value('IS%26P', nil, record[:id]), filter_by_date_range('PO Date', @date_range)]), target: '_blank'),

              ]
end
json.recordsTotal @records.count
json.recordsFiltered @records.total_count
json.draw params[:draw]
