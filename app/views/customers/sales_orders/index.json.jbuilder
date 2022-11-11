json.data (@sales_orders) do |sales_order|
  columns = [
                  [
                      if policy(sales_order).index?
                        row_action_button(customers_order_path(sales_order), 'eye', 'View Order', 'info')
                      end,
                      if policy(sales_order).index? && !is_api_request?
                        row_action_button(customers_order_path(sales_order, format: :pdf), 'file-pdf', 'Download Order', 'dark', :_blank)
                      end
                  ].join(' '),
                  sales_order.inquiry.company.to_s,
                  sales_order.order_number,
                  format_date(sales_order.created_at),
                  sales_order.inquiry.customer_po_number,
                  format_date(sales_order.inquiry.customer_order_date),
                  sales_order.inquiry.inquiry_number,
                  sales_order.inquiry.shipping_contact.try(:name) || sales_order.inquiry.billing_contact.try(:name),
                  format_currency(sales_order.calculated_total),
                  format_date(sales_order.inquiry.customer_committed_date),
                  sales_order.invoices.any? ? format_date(sales_order.invoices.last.delivery_date || sales_order.invoices.last.mis_date) : '-',
                  sap_status(sales_order.get_invoiced_qty, sales_order.total_qty),
                  format_date(sales_order.created_at)
              ]
  columns.delete_at(1) unless policy(current_customers_contact).admin_columns?
  json.merge! columns
end

json.columnFilters [
                       [],
                       @sales_orders.map {|sales_order| {label: sales_order.inquiry.company.to_s, value: sales_order.company.id}}.uniq,
                       [],
                       [],
                       [],
                       [],
                       [],
                       [{ "source": autocomplete_overseers_company_contacts_path(current_company) }],
                       [],
                       [],
                       [],
                       [{label: "Delivered", value: 1}, {label: "Processed", value: 3}]

                   ]

json.recordsTotal @sales_orders.count
json.recordsFiltered @indexed_sales_orders.total_count
json.draw params[:draw]
