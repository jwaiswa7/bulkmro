json.data (@companies) do |company|
  json.array! [
                  [
                      if policy(company).show?
                        row_action_button(overseers_company_path(company), 'eye', 'View Company', 'info', :_blank)
                      end,
                      if policy(company).edit?
                        row_action_button(edit_overseers_account_company_path(company.account, company), 'pencil', 'Edit Company', 'warning', :_blank)
                      end,
                      # if policy(company).edit?;
                      #   row_action_button(overseers_company_customer_products_path(company), 'list', 'Company Products', 'success', '_blank')
                      # end,
                      if policy(company).new_contact?
                        row_action_button(new_overseers_contact_path(company_id: company.to_param), 'user', 'New Contact', 'success', :_blank)
                      end,
                      if policy(company).new_address?
                        row_action_button(new_overseers_company_address_path(company), 'map-marker-alt', 'New Address', 'success', :_blank)
                      end,
                      if policy(company).new_inquiry?
                        row_action_button(new_overseers_inquiry_path(company_id: company.to_param), 'plus-circle', 'New Inquiry', 'success', :_blank)
                      end# ,
                    # if policy(company).new_rating?
                    #   link_to('', class: ['btn btn-sm btn-warning rating '], :'data-company-id' => company.id, :remote => true) do
                    #     concat content_tag(:span, '')
                    #     concat content_tag :i, nil, class: ['fal fa-star'].join
                    #   end
                    # end
                  ].join(' '),
                  conditional_link(company.to_s,  overseers_company_path(company), policy(company).show?),
                  conditional_link(company.account.name.to_s,  overseers_account_path(company.account), policy(company.account).show?),
                  company.nature_of_business&.titleize || '-',
                  company.billing_address&.to_multiline_s,
                  company.default_contact&.name || '-',
                  if company.is_supplier? && company.rating.present? && company.rating > 0
                    format_star(company.rating)
                  end,
                  company.purchase_orders.count,
                  company.supplied_brands&.uniq&.count,
                  company.supplied_products&.uniq&.count,
                  company.supplied_brands.map(&:name)&.uniq&.join(', ').upcase,
                  format_succinct_date(company.created_at)
              ]
end

json.columnFilters [
                       [],
                       [],
                       [{ "source": autocomplete_supplier_overseers_accounts_path }],
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

json.recordsTotal @companies.model.all.count
json.recordsFiltered @indexed_companies.total_count
json.draw params[:draw]
