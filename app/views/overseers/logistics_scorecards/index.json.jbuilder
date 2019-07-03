json.data (@logistics_scorecard_records) do |record|
  json.array! [
                  [
                      modal_button('user-clock', 'Add Delay Reason', 'warning', record[:id])
                  ],
                  record[:inquiry_number],
                  record[:inquiry_date].present? ? format_date_without_time(Date.parse(record[:inquiry_date])) : '--',
                  record[:company],
                  record[:inside_sales_owner],
                  record[:logistics_owner],
                  record[:opportunity_type].present? ? Inquiry.opportunity_types.key(record[:opportunity_type]).titleize : '--',
                  record[:sku],
                  record[:sku_description],
                  record[:item_make],
                  record[:quantity],
                  record[:delivery_location],
                  record[:customer_po_date].present? ? format_date_without_time(Date.parse(record[:customer_po_date])) : '--',
                  record[:customer_po_received_date].present? ? format_date_without_time(Date.parse(record[:customer_po_received_date])) : '--',
                  record[:cp_committed_date].present? ? format_date_without_time(Date.parse(record[:cp_committed_date])) : '--',
                  record[:so_created_at].present? ? format_date_without_time(Date.parse(record[:so_created_at])) : '--',
                  record[:actual_delivery_date].present? ? format_date_without_time(Date.parse(record[:actual_delivery_date])) : '--',
                  record[:committed_delivery_tat].present? ? record[:committed_delivery_tat] : '--',
                  record[:actual_delivery_tat].present? ? record[:actual_delivery_tat] : '--',
                  record[:delay].present? ? record[:delay] : '--',
                  record[:sla_bucket].present? ? record[:sla_bucket] : '--',
                  record[:delay_bucket].present? ? SalesInvoice.delay_buckets.key(record[:delay_bucket]) : 'Not Delivered',
                  record[:delay_reason].present? ? SalesInvoice.delay_reasons.key(record[:delay_reason]) : '--',
                  record[:cp_committed_month].present? ? Date.parse(record[:cp_committed_month]).strftime("%B %Y") : '-'
              ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       [],
                       Overseer.where(role: 'logistics').alphabetical.map {|s| {"label": s.full_name, "value": s.id.to_s}}.reject { |h| h[:label] == 'Logistics Team'}.as_json,
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
                       SalesInvoice.delay_buckets.map { |k, v| { "label": k, "value": v.to_s } }.as_json,
                       SalesInvoice.delay_reasons.map { |k, v| { "label": k, "value": v.to_s } }.as_json,
                       []
]

json.recordsTotal @logistics_scorecard_records.count
json.recordsFiltered @logistics_scorecard_records.total_count
json.draw params[:draw]
