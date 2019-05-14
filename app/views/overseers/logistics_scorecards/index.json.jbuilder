json.data (@logistics_scorecard_records) do |record|
  json.array! [
                  record[:inquiry_number],
                  record[:inquiry_date].present? ? format_date_without_time(Date.parse(record[:inquiry_date])) : '-',
                  record[:company],
                  record[:inside_sales_owner],
                  record[:logistics_owner],
                  record[:opportunity_type].present? ? Inquiry.opportunity_types.key(record[:opportunity_type]) : '-',
                  record[:sku],
                  record[:sku_description],
                  record[:item_make],
                  record[:quantity],
                  record[:delivery_location],
                  record[:customer_po_date].present? ? format_date_without_time(Date.parse(record[:customer_po_date])) : '-',
                  record[:customer_po_received_date].present? ? format_date_without_time(Date.parse(record[:customer_po_received_date])) : '-',
                  record[:cp_committed_date].present? ? format_date_without_time(Date.parse(record[:cp_committed_date])) : '-',
                  record[:so_created_at].present? ? format_date_without_time(Date.parse(record[:so_created_at])) : '-',
                  record[:actual_delivery_date].present? ? format_date_without_time(Date.parse(record[:actual_delivery_date])) : '-',
                  record[:committed_delivery_tat].present? ? record[:committed_delivery_tat] : '-',
                  record[:actual_delivery_tat].present? ? record[:actual_delivery_tat] : '-',
                  record[:delay].present? ? record[:delay] : '-'
              ]
end

json.recordsTotal @logistics_scorecard_records.count
json.recordsFiltered @logistics_scorecard_records.total_count
json.draw params[:draw]
