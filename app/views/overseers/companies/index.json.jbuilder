json.data (@companies) do |company|
  json.array! [
                  [
                      if is_authorized(company, 'show');
                         row_action_button_without_fa(overseers_company_path(company), 'bmro-icon-table bmro-icon-used-view', 'View Company', 'info', :_blank)
                      end,
                      if is_authorized(company, 'edit');
                         row_action_button_without_fa(edit_overseers_account_company_path(company.account, company), 'bmro-icon-table bmro-icon-pencil', 'Edit Company', 'warning', :_blank)
                      end,
                      # if is_authorized(company, 'edit');
                      #   row_action_button(overseers_company_customer_products_path(company), 'list', 'Company Products', 'success', '_blank')
                      # end,
                      if is_authorized(company, 'new_contact');
                         row_action_button_without_fa(new_overseers_contact_path(company_id: company.to_param), 'bmro-icon-table bmro-icon-new-contact', 'New Contact', 'success', :_blank)
                      end,
                      if is_authorized(company, 'new_address');
                         row_action_button_without_fa(new_overseers_company_address_path(company), 'bmro-icon-table bmro-icon-new-address', 'New Address', 'success', :_blank)
                      end,
                      if is_authorized(company, 'new_inquiry') && policy(company).new_inquiry?;
                         row_action_button_without_fa(new_overseers_inquiry_path(company_id: company.to_param), 'bmro-icon-table bmro-icon-sighnature-plus', 'New Inquiry', 'success', :_blank)
                      end# ,
                    # if is_authorized(company, 'new_rating')
                    #   link_to('', class: ['btn btn-sm btn-warning rating '], :'data-company-id' => company.id, :remote => true) do
                    #     concat content_tag(:span, '')
                    #     concat content_tag :i, nil, class: ['fal fa-star'].join
                    #   end
                    # end
                  ].join(' '),


                  conditional_link(company.to_s,  overseers_company_path(company), is_authorized(company, 'show')),
                  conditional_link(company.account.name.to_s,  overseers_account_path(company.account), is_authorized(company.account, 'show')),
                  company.addresses.size,
                  company.contacts.size,
                  company.inquiries.size,
                  company.customer_products.size,
                  (company.addresses.present? && company.is_international) ? 'International' : company.pan,
                  format_boolean(company.validate_pan),
                  if company.is_supplier? && company.rating.present? && company.rating > 0
                    format_star(company.rating)
                  elsif company.is_supplier?
                    format_star(rand(3.0..4.8).round(1))
                  end,
                  format_boolean(company.is_supplier?),
                  format_boolean(company.is_customer?),
                  format_boolean_label(company.synced?, 'synced'),
                  format_succinct_date(company.created_at)
              ]
end

json.columnFilters [
                       [],
                       [],
                       [{ "source": autocomplete_overseers_accounts_path }],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [{ "label": 'Yes', "value": true }, { "label": 'No', "value": false }],
                       [],
                       [],
                       [],
                       [],
                       []
                   ]

json.recordsTotal @companies.model.all.count
json.recordsFiltered @indexed_companies.total_count
json.draw params[:draw]
