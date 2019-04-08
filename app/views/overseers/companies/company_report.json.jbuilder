json.data (@indexed_company_reports) do |inquiry|
  json.array! [
                  [],
                  inquiry['company'],
                  number_with_delimiter(inquiry['doc_count'], delimiter: ','),
                  number_with_delimiter(inquiry['sales_quotes']['value'].to_i, delimiter: ','),
                  format_currency(inquiry['total_sales_value']['value']),
                  number_with_delimiter(inquiry['expected_orders']['value'].to_i, delimiter: ','),
                  format_currency(inquiry['total_sales_value']['value']),
                  number_with_delimiter(inquiry['sales_orders']['value'].to_i, delimiter: ','),
                  format_currency(inquiry['total_order_value']['value']),
                  number_with_delimiter(inquiry['sku']['value'].to_i, delimiter: ','),
                  inquiry['orders_won']['value'].to_i > 0 ? percentage(inquiry['orders_won']['value'] * 100.0 / inquiry['doc_count']) : '-',
                  number_with_delimiter(inquiry['sales_invoices']['value'].to_i, delimiter: ','),
                  format_currency(inquiry['revenue']['value']),
                  # number_with_delimiter(inquiry['clients']['value'].to_i, delimiter: ',')
              ]
end

json.columnFilters [
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
                       # [],
                       # [],
                       # [],
                       # []
                   ]

json.recordsTotal @indexed_company_reports.length
json.recordsFiltered @indexed_company_reports.length
json.draw params[:draw]