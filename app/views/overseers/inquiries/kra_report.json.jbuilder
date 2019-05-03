json.data (@indexed_kra_reports) do |inquiry|
  json.array! [
                  [],
                  if @date_range.present?
                    if @category.present? && @category == 'company_key'
                      link_to(Company.find(inquiry['key']).to_s, overseers_company_path(inquiry['key']), target: '_blank')
                    else
                      link_to(Overseer.find(inquiry['key']).to_s, filtered_path(kra_report_per_sales_owner_overseers_inquiries_path, [filter_by_value('Name', Overseer.find(inquiry['key']).to_s, inquiry['key']), filter_by_date_range('Date+of+inquiry', @date_range)]), target: '_blank')
                    end
                  else
                    if @category.present? && @category == 'company_key'
                      link_to(Company.find(inquiry['key']).to_s, overseers_company_path(inquiry['key']), target: '_blank')
                    else
                      link_to(Overseer.find(inquiry['key']).to_s, filtered_path(kra_report_per_sales_owner_overseers_inquiries_path, [filter_by_value('Name', Overseer.find(inquiry['key']).to_s, inquiry['key'])]), target: '_blank')
                    end
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
                       if @category.present? && @category == 'company_key'
                         [{"source": autocomplete_overseers_companies_path}]
                       else
                         Overseer.inside.alphabetical.map {|s| {"label": s.full_name, "value": s.id.to_s}}.as_json
                       end,
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

json.recordsTotal @indexed_kra_reports.count
json.recordsFiltered @indexed_kra_reports.total_count
json.draw params[:draw]
