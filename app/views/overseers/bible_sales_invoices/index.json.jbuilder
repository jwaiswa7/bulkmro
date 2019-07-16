json.data (@sales_invoices) do |sales_invoice|
  json.array! [
                  '',
                  sales_invoice.branch_type,
                  sales_invoice.invoice_number,
                  format_succinct_date(sales_invoice.mis_date),
                  sales_invoice.inquiry_number,
                  sales_invoice.company_name,
                  sales_invoice.inside_sales_owner.to_s,
                  sales_invoice.invoice_type,
                  format_currency(sales_invoice.invoice_total),
                  percentage(sales_invoice.overall_margin_percentage)
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
                       []
                   ]


json.recordsTotal BibleSalesOrder.all.count
json.recordsFiltered @sales_invoices.total_count
json.draw params[:draw]
