json.data (@indexed_kra_reports) do |inquiry|
  json.array! [
                  [],
                  Overseer.find(inquiry['key']).to_s,
                  inquiry['doc_count'],
                  inquiry['sales_invoices']['value'],
                  inquiry['sales_orders']['value'],
                  inquiry['expected_orders']['value'],
                  inquiry['orders_won']['value'],
  ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       []
                   ]

json.recordsTotal Inquiry.all.count
json.recordsFiltered @indexed_kra_reports.length
json.draw params[:draw]
json.kra_reports @indexed_kra_reports
