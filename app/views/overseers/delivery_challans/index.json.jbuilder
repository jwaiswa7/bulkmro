json.data (@delivery_challans) do |delivery_challan|
  json.array! [
                  if delivery_challan.sales_order.present? && is_authorized(delivery_challan, 'can_create_ar_invoice') && (policy(delivery_challan).create_ar_invoice?) && delivery_challan.sales_order.remote_uid.present?
                    "<div class='d-inline-block custom-control custom-checkbox align-middle'><input type='checkbox' name='the_delivery_challans[]' class='custom-control-input' value='#{delivery_challan.id}' id='c-#{delivery_challan.id}' data-so-id='#{delivery_challan.sales_order.id}'><label class='custom-control-label' for='c-#{delivery_challan.id}'></label></div>"
                  end,
                  [
                      if is_authorized(delivery_challan, 'relationship_map') && policy(delivery_challan).relationship_map?
                        row_action_button(relationship_map_overseers_delivery_challan_path(delivery_challan.to_param), 'sitemap', 'Relationship Map', 'info', :_blank)
                      end,
                      if is_authorized(delivery_challan, 'edit')
                        row_action_button(edit_overseers_delivery_challan_path(delivery_challan.to_param), 'pencil', 'Edit', 'info', :_blank)
                      end,
                      if is_authorized(delivery_challan, 'show')
                        [
                            row_action_button(overseers_delivery_challan_path(delivery_challan.to_param), 'eye', 'View', 'info', :_blank),
                            row_action_button(overseers_delivery_challan_path(delivery_challan, format: :pdf), 'download', 'Pdf Without Signature', 'success', :_blank, 'get','', false, 'O'),
                            row_action_button(overseers_delivery_challan_path(delivery_challan.to_param, stamp: 1, format: :pdf), 'file-alt', 'Pdf with Signature', 'success', :_blank, 'get', '', false, 'O')
                        ]
                      end,
                      if delivery_challan.sales_order.present? && (policy(delivery_challan).create_ar_invoice?) && delivery_challan.sales_order.remote_uid.present?
                        row_action_button_without_fa(new_overseers_ar_invoice_request_path(sales_order_id: delivery_challan.sales_order, delivery_challan_ids: delivery_challan.id), 'bmro-icon-table bmro-icon-circle', 'Create AR Invoice Request', 'success', target: :_blank)
                      elsif delivery_challan.sales_order.present? && is_authorized(delivery_challan, 'can_create_ar_invoice') && (policy(delivery_challan).create_ar_invoice?) && delivery_challan.sales_order.remote_uid.blank?
                        link_to('', class: 'btn btn-sm btn-success able_to_create_ar_invoice', 'data-sales-order-number': delivery_challan.sales_order.order_number, title: 'Create AR Invoice', remote: true) do
                          concat content_tag(:span, '')
                          concat content_tag :i, nil, class: ['bmro-icon-table bmro-icon-circle'].join
                        end
                        #row_action_button('#', 'plus', 'View Inward Dispatch', 'success')
                      end,
                  ].join(' '),
                  link_to(delivery_challan.delivery_challan_number,overseers_delivery_challan_path(delivery_challan.to_param), target: '_blank'),
                  link_to(delivery_challan.inquiry.inquiry_number, edit_overseers_inquiry_path(delivery_challan.inquiry), target: '_blank'),
                  delivery_challan.sales_order.present? ? link_to(delivery_challan.sales_order.order_number, overseers_inquiry_sales_order_path(delivery_challan.sales_order.inquiry, delivery_challan.sales_order), target: '_blank') : ' - ',
                  delivery_challan.total_qty,
                  delivery_challan.sales_order.present? ? [delivery_challan.total_qty, ' of ', delivery_challan.sales_order.total_qty].join : '-',
                  format_succinct_date(delivery_challan.created_at),
                  link_to(delivery_challan.inquiry.company.to_s, overseers_company_path(delivery_challan.inquiry.company), target: '_blank'),
                  delivery_challan.inquiry.billing_contact.to_s,
                  delivery_challan.inquiry.shipping_contact.to_s,
                  delivery_challan.created_by.try(:name)
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
                       [{ "source": autocomplete_overseers_companies_path }],
                       [],
                       [],
                       Overseer.where(id: DeliveryChallan.pluck(:created_by_id)).alphabetical.map { |s| { "label": s.full_name, "value": s.id.to_s } }.as_json
                   ]

json.recordsTotal @delivery_challans.count
json.recordsFiltered @indexed_delivery_challans.total_count
json.draw params[:draw]