# frozen_string_literal: true

json.data (@sales_orders) do |sales_order|
  json.array! [
                  [
                      if policy(sales_order).index?
                        row_action_button(customers_order_path(sales_order), "eye", "View Order", "info")
                      end,
                      if policy(sales_order).index?
                        row_action_button(customers_order_path(sales_order, format: :pdf), "file-pdf", "Download Order", "dark", :_blank)
                      end
                  ].join(" "),
                  sales_order.order_number,
                  format_date(sales_order.created_at),
                  sales_order.inquiry.customer_po_number,
                  format_date(sales_order.inquiry.customer_order_date),
                  sales_order.inquiry.inquiry_number,
                  sales_order.inquiry.shipping_contact.try(:name) || sales_order.inquiry.billing_contact.try(:name),
                  sales_order.inquiry.company.to_s,
                  format_currency(sales_order.calculated_total),
                  format_date(sales_order.inquiry.customer_committed_date),
                  sales_order.invoices.any? ? format_date(sales_order.invoices.last.delivery_date || sales_order.invoices.last.mis_date) : "-",
                  status_badge(sales_order.effective_customer_status)
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
                       []

                   ]

json.recordsTotal @sales_orders.count
json.recordsFiltered @indexed_sales_orders.total_count
json.draw params[:draw]
