json.data (@indexed_company_reports) do |inquiry|
  json.array! [
                  [],
                  Company.find( inquiry['key']).name,
                  Company.find( inquiry['key']).account.name,
                  Company.find( inquiry['key']).inquiry_size,
                  number_with_delimiter(inquiry['sales_quotes']['value'].to_i, delimiter: ','),
                  format_currency(inquiry['total_sales_value']['value']),
                  number_with_delimiter(inquiry['expected_orders']['value'].to_i, delimiter: ','),
                  format_currency(inquiry['total_expected_value']['value']),
                  number_with_delimiter(inquiry['total_sales_orders']['value'].to_i, delimiter: ','),
                  format_currency(inquiry['total_order_value']['value']),
                  format_currency(inquiry['order_margin']['value']),
                   percentage(inquiry['margin_percentage']['value']),
                  number_with_delimiter(inquiry['sales_invoices']['value'].to_i, delimiter: ','),
                  format_currency(inquiry['amount_invoiced']['value']),
                  percentage(inquiry['invoice_margin']['value']),
                  number_with_delimiter(inquiry['cancelled_invoiced']['value'].to_i, delimiter: ','),
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
                       [],
                       [],
                       []
                   ]

json.recordsTotal @indexed_company_reports.length
json.recordsFiltered @indexed_company_reports.length
json.draw params[:draw]