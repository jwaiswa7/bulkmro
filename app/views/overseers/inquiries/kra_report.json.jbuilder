json.data (@indexed_kra_reports) do |inquiry|
  json.array! [
                  [],
                  Overseer.find(inquiry['key']).to_s,
                  inquiry['doc_count'],
                  inquiry['sales_invoices']['value'],
                  inquiry['sales_orders']['value'],
                  inquiry['expected_orders']['value'],
                  percentage(inquiry['orders_won']['value'] * 100 / inquiry['doc_count']),
  ]
end

json.columnFilters [
                       [],
                       Overseer.inside.alphabetical.map { |s| { "label": s.full_name, "value": s.id.to_s } }.as_json,
                       [],
                       [],
                       [],
                       [],
                       []
                   ]

json.recordsTotal @indexed_kra_reports.length
json.recordsFiltered @indexed_kra_reports.length
json.draw params[:draw]
json.kra_reports @indexed_kra_reports
