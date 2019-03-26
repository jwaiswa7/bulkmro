json.data (@indexed_kra_reports) do |inquiry|
  json.array! [
                  [],
                  Overseer.find(inquiry['key']).to_s,
                  if @date_range.present?
                    link_to(number_with_delimiter(inquiry['doc_count'], delimiter: ','), filtered_path(overseers_inquiries_path, [filter_by_value('Inside Sales', Overseer.find(inquiry['key']).to_s, inquiry['key']), filter_by_date_range('Date', @date_range)]), target: '_blank')
                  else
                    link_to(number_with_delimiter(inquiry['doc_count'], delimiter: ','), filtered_path(overseers_inquiries_path, [filter_by_value('Inside Sales', Overseer.find(inquiry['key']).to_s, inquiry['key'])]), target: '_blank')
                  end,
                  if @date_range.present?
                    link_to(number_with_delimiter(inquiry['sales_invoices']['value'], delimiter: ','), filtered_path(overseers_sales_invoices_path, [filter_by_value('IS%26P', Overseer.find(inquiry['key']).to_s, inquiry['key']), filter_by_date_range('Date', @date_range)]), target: '_blank')
                  else
                    link_to(number_with_delimiter(inquiry['sales_invoices']['value'], delimiter: ','), filtered_path(overseers_sales_invoices_path, [filter_by_value('IS%26P', Overseer.find(inquiry['key']).to_s, inquiry['key'])]), target: '_blank')
                  end,
                  number_with_delimiter(inquiry['sales_orders']['value']),
                  inquiry['expected_orders']['value'],
                  percentage(inquiry['orders_won']['value'] * 100 / inquiry['doc_count']),
                  number_with_delimiter(inquiry['clients']['value'])
              ]
end

json.columnFilters [
                       [],
                       Overseer.inside.alphabetical.map {|s| {"label": s.full_name, "value": s.id.to_s}}.as_json,
                       [],
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
