json.data (@delivery_challans) do |delivery_challan|
  json.array! [

                  [
                      if is_authorized(delivery_challan, 'show')
                        row_action_button(overseers_delivery_challan_path(delivery_challan.to_param), 'eye', 'View', 'info', :_blank)
                        row_action_button(overseers_delivery_challan_path(delivery_challan.to_param, stamp: 1, format: :pdf), 'file-alt', 'Pdf with Signature', 'success', :_blank, 'get', '', false, 'O')
                      end,
                  ].join(' '),
                  delivery_challan.delivery_challan_number,
                  delivery_challan.inquiry.inquiry_number,
                  delivery_challan.sales_order.order_number,
                  delivery_challan.total_qty,
                  delivery_challan.sales_order.present? ? [delivery_challan.total_qty, ' of ', delivery_challan.sales_order.total_qty].join : '-',
                  format_succinct_date(delivery_challan.created_at),
                  delivery_challan.inquiry.company.to_s,
                  delivery_challan.inquiry.billing_contact.to_s,
                  delivery_challan.inquiry.shipping_contact.to_s,
                  delivery_challan.created_by.to_s
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
                       [{ "source": autocomplete_overseers_companies_path }],
                       [],
                       [],
                       Overseer.where(id: DeliveryChallan.pluck(:created_by_id)).alphabetical.map { |s| { "label": s.full_name, "value": s.id.to_s } }.as_json
                   ]

json.recordsTotal @delivery_challans.count
json.recordsFiltered @indexed_delivery_challans.total_count
json.draw params[:draw]