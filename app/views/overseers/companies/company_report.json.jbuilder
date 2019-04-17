json.data (@indexed_company_reports) do |inquiry|
  json.array! [
                  [],
                  link_to(Company.find(inquiry['key']).name, overseers_company_path(inquiry['key']), target: '_blank'),
                  link_to(Company.find(inquiry['key']).account.name, overseers_account_path(Company.find(inquiry['key']).account), target: '_blank'),
                  number_with_delimiter(inquiry['total_inquiries']['value'].to_i, delimiter: ','),
                  number_with_delimiter(inquiry['inquiries_size']['value'].to_i, delimiter: ','),
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
                       [{"source": autocomplete_overseers_companies_path}],
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