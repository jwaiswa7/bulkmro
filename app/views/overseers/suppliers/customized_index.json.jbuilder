json.data (@companies) do |company|
  json.array! [
                  [
                      "<div class='d-inline-block custom-control custom-checkbox align-middle'><input type='checkbox' name='suppliers[]' class='custom-control-input' value='#{company.id}' id='c-#{company.id}'><label class='custom-control-label' for='c-#{company.id}'></label></div>"
                  ].join(' '),
                  conditional_link(company.to_s,  overseers_company_path(company), is_authorized(company, 'show')),
                  conditional_link(company.account.name.to_s,  overseers_account_path(company.account), is_authorized(company.account, 'show')),
                  company.nature_of_business&.titleize || '-',
                  company.billing_address&.to_multiline_s,
                  company.default_contact&.name || '-',
                  if company.is_supplier? && company.rating.present? && company.rating > 0
                    format_star(company.rating)
                  elsif company.is_supplier?
                    format_star(rand(3.0..4.8).round(1))
                  end,
                  company.purchase_orders.count,
                  company.supplied_brands&.uniq&.count,
                  company.supplied_products&.uniq&.count,
                  company.supplied_brands.map(&:name)&.uniq&.join(', ').upcase,
                  company.created_by.to_s,
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
                       [{ "source": autocomplete_overseers_brands_path }],
                       [],
                       []
                   ]

json.recordsTotal @companies.model.all.count
json.recordsFiltered @indexed_companies.total_count
json.draw params[:draw]
