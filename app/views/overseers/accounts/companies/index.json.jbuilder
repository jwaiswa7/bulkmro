json.data (@companies) do |company|
  json.array! [
                  [
                      if is_authorized(company, 'show');
                        row_action_button(overseers_company_path(company), 'eye', 'View Company', 'info', :_blank)
                      end,
                      if is_authorized(company, 'edit');
                        row_action_button(edit_overseers_account_company_path(company.account, company), 'pencil', 'Edit Company', 'warning', :_blank)
                      end,
                      # if is_authorized(company, 'edit');
                      #   row_action_button(overseers_company_customer_products_path(company), 'list', 'Company Products', 'success', '_blank')
                      # end,
                      if is_authorized(company, 'edit');
                        row_action_button_without_fa(new_overseers_contact_path(company_id: company.to_param), 'bmro-user-icon', 'New Contact', 'success', :_blank)
                      end,
                      if is_authorized(company, 'edit');
                        row_action_button(new_overseers_company_address_path(company), 'map-marker-alt', 'New Address', 'success', :_blank)
                      end,
                      if is_authorized(company, 'new_inquiry') && policy(company).new_inquiry?;
                        row_action_button_without_fa(new_overseers_inquiry_path(company_id: company.to_param), 'bmro-plus-circle-icon', 'New Inquiry', 'success', :_blank)
                      end,
                  ].join(' '),
                  link_to(company.to_s, overseers_company_path(company), target: '_blank'),
                  if company.is_supplier? && company.rating.present? && company.rating > 0
                    format_star(company.rating)
                  elsif company.is_supplier?
                    format_star(rand(3.0..4.8).round(1))
                  end,
                  company.addresses.size,
                  company.contacts.size,
                  company.inquiries.size,
                  (company.addresses.present? && company.is_international) ? 'International' : company.pan,
                  format_boolean(company.validate_pan),
                  format_boolean(company.is_supplier?),
                  format_boolean(company.is_customer?),
                  format_boolean_label(company.synced?, 'synced'),
                  format_succinct_date(company.created_at),
              ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [{ "label": 'Yes', "value": true }, { "label": 'No', "value": false }],
                       [],
                       [],
                       [],
                       []
                   ]
json.recordsTotal Company.count
json.recordsFiltered @indexed_companies.total_count
json.draw params[:draw]
