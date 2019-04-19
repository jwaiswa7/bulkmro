json.data (@indexed_kra_reports) do |inquiry|
  json.array! [
                  [],
                  if @date_range.present?
                    link_to(Overseer.find(inquiry['key']).to_s, filtered_path(kra_report_per_sales_owner_overseers_inquiries_path, [filter_by_value('Name', Overseer.find(inquiry['key']).to_s, inquiry['key']), filter_by_date_range('Date+of+inquiry', @date_range)]), target: '_blank')
                  else
                    link_to(Overseer.find(inquiry['key']).to_s, filtered_path(kra_report_per_sales_owner_overseers_inquiries_path, [filter_by_value('Name', Overseer.find(inquiry['key']).to_s, inquiry['key'])]), target: '_blank')
                  end,
                  number_with_delimiter(inquiry['doc_count'], delimiter: ','),
                  number_with_delimiter(inquiry['sales_quotes']['value'].to_i, delimiter: ','),
                  format_currency(inquiry['total_sales_value']['value']),
                  number_with_delimiter(inquiry['expected_orders']['value'].to_i, delimiter: ','),
                  format_currency(inquiry['total_sales_value']['value']),
                  number_with_delimiter(inquiry['sales_orders']['value'].to_i, delimiter: ','),
                  format_currency(inquiry['total_order_value']['value']),
                  number_with_delimiter(inquiry['sku']['value'].to_i, delimiter: ','),
                  inquiry['orders_won']['value'].to_i > 0 ? percentage(inquiry['orders_won']['value'] * 100.0 / inquiry['doc_count']) : 0,
                  number_with_delimiter(inquiry['sales_invoices']['value'].to_i, delimiter: ','),
                  format_currency(inquiry['revenue']['value']),
                  number_with_delimiter(inquiry['clients']['value'].to_i, delimiter: ',')
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
                       [],
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
