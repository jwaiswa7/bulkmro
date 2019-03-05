json.data (@sales_receipts) do |sales_receipt|
  json.array! [
                [
                    if policy(sales_receipt).show?
                      row_action_button(overseers_sales_receipt_path(sales_receipt), 'eye', 'View Company', 'info', :_blank)
                    end
                ],
                sales_receipt.company_id.present? ? sales_receipt.company.account.alias : '',
                sales_receipt.company_id.present? ? sales_receipt.company.to_s : '',
                sales_receipt.sales_invoice_id.present? ? sales_receipt.sales_invoice.invoice_number : ' - ',
                sales_receipt.sales_invoice_id.present? ? format_succinct_date(sales_receipt.sales_invoice.created_at) : ' - ',
                ' - ',
                sales_receipt.payment_received_date.present? ? format_succinct_date(sales_receipt.payment_received_date) : ' - ',
                sales_receipt.payment_type.present? ? sales_receipt.payment_type.titlecase : '',
                sales_receipt.payment_method.present? ? sales_receipt.payment_method.titlecase : '',
                sales_receipt.currency_id.present? ? sales_receipt.currency.name : ' - ',
                sales_receipt.payment_amount_received.present? ? format_currency(sales_receipt.payment_amount_received) : ' - ',
                sales_receipt.remote_reference.present? ? sales_receipt.remote_reference : ' - ',
                sales_receipt.comments.present? ? sales_receipt.comments : ' - ',
                format_succinct_date(sales_receipt.created_at)
               ]
end
json.columnFilters [
                      [],
                      [],
                      [{ "source": autocomplete_overseers_companies_path }],
                      [],
                      [],
                      [],
                      [],
                      SalesReceipt.payment_types.map { |k, v| { "label": k.titlecase, "value": v.to_s } }.as_json,
                      SalesReceipt.payment_methods.map { |k, v| { "label": k.titlecase, "value": v.to_s } }.as_json,
                      Currency.all.map { |v| { "label": v.name, "value": v.id } }.as_json,
                      [],
                      [],
                      [],
                      [],
                   ]

json.recordsTotal @sales_receipts.model.all.count
json.recordsFiltered @indexed_sales_receipts.total_count
json.draw params[:draw]
