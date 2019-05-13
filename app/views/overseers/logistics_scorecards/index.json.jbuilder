json.data (@logistics_scorecard_records) do |record|
  json.array! [
                  record.inquiry_number,
                  record.inquiry_date,
                  record.company,
                  record.inside_sales_owner,
                  record.logistics_owner,
                  record.opportunity_type,
                  record.sku,
                  record.sku_description,
                  record.item_make,
                  record.quantity,
                  record.delivery_location,
                  format_succinct_date(record.customer_po_date),
                  format_succinct_date(record.customer_po_received_date),
                  format_succinct_date(record.cp_committed_date),
                  format_succinct_date(record.so_created_at)
              ]
end

json.recordsTotal @logistics_scorecard_records.count
json.recordsFiltered @logistics_scorecard_records.total_count
json.draw params[:draw]
