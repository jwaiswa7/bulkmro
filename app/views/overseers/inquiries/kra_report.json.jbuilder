json.data (@indexed_kra_reports) do |inquiry|
  json.array! [
                  [],
                  if @date_range.present?
                    if @category.present? && @category == 'company_key'
                      link_to(Company.find(inquiry['key']).to_s, overseers_company_path(inquiry['key']), target: '_blank')
                    else
                      link_to(Overseer.find(inquiry['key']).to_s, filtered_path(kra_report_per_sales_owner_overseers_inquiries_path, [filter_by_value('Name', Overseer.find(inquiry['key']).to_s, inquiry['key']), filter_by_date_range('Date+of+inquiry', @date_range)]), target: '_blank')
                    end
                  else
                    if @category.present? && @category == 'company_key'
                      link_to(Company.find(inquiry['key']).to_s, overseers_company_path(inquiry['key']), target: '_blank')
                    else
                      link_to(Overseer.find(inquiry['key']).to_s, filtered_path(kra_report_per_sales_owner_overseers_inquiries_path, [filter_by_value('Name', Overseer.find(inquiry['key']).to_s, inquiry['key'])]), target: '_blank')
                    end
                  end,
                  if @category.present? && @category == 'company_key'
                    link_to(Company.find(inquiry['key']).account.to_s, overseers_account_path(Company.find(inquiry['key']).account), target: '_blank')
                  end,
                  number_with_delimiter(inquiry['doc_count'], delimiter: ','),
                  number_with_delimiter(inquiry['sales_quote_count']['value'].to_i, delimiter: ','),
                  inquiry['total_quote_value']['value'].to_i,
                  number_with_delimiter(inquiry['expected_order']['value'].to_i, delimiter: ','),
                  inquiry['total_quote_value']['value'].to_i,
                  if  @category.present? && (@category.include?'by_sales_order')
                    number_with_delimiter(@indexed_kra_varient_reports[inquiry['key']]['sales_orders']['value'].to_i, delimiter: ',') if @indexed_kra_varient_reports[inquiry['key']].present?
                  else
                    number_with_delimiter(inquiry['sales_order_count']['value'].to_i, delimiter: ',')
                  end,
                  if @category.present? && (@category.include? 'by_sales_order')
                    @indexed_kra_varient_reports[inquiry['key']]['total_order_value']['value'].to_i if @indexed_kra_varient_reports[inquiry['key']].present?
                  else
                    inquiry['total_order_value']['value'].to_i
                  end,
                  if @category.present? && (@category.include? 'by_sales_order')
                    number_with_delimiter(@indexed_kra_varient_reports[inquiry['key']]['sku']['value'].to_i, delimiter: ',') if @indexed_kra_varient_reports[inquiry['key']].present?
                  else
                    number_with_delimiter(inquiry['sku']['value'].to_i, delimiter: ',')
                  end,
                  if @category.present? && (@category.include? 'by_sales_order')
                    @indexed_kra_varient_reports[inquiry['key']]['order_won']['value'].to_i > 0 ? percentage(@indexed_kra_varient_reports[inquiry['key']]['order_won']['value'] * 100.0 / @indexed_kra_varient_reports[inquiry['key']]['doc_count'], show_symbol: false) : 0 if @indexed_kra_varient_reports[inquiry['key']].present?
                  else
                    inquiry['order_won']['value'].to_i > 0 ? percentage(inquiry['order_won']['value'] * 100.0 / inquiry['doc_count'], show_symbol: false) : 0
                  end,
                  if @category.present? && (@category.include? 'by_sales_order')
                    number_with_delimiter(@indexed_kra_varient_reports[inquiry['key']]['invoices_count']['value'].to_i, delimiter: ',') if @indexed_kra_varient_reports[inquiry['key']].present?
                  else
                    number_with_delimiter(inquiry['invoices_count']['value'].to_i, delimiter: ',')
                  end,
                  if @category.present? && (@category.include? 'by_sales_order')
                    @indexed_kra_varient_reports[inquiry['key']]['revenue']['value'].to_i if @indexed_kra_varient_reports[inquiry['key']].present?
                  else
                    inquiry['revenue']['value'].to_i
                  end
              ]
end

json.columnFilters [
                       [],
                       if @category.present? && @category == 'company_key'
                         [{"source": autocomplete_overseers_companies_path}]
                       elsif @category.present? && (@category.include? 'outside')
                         Inquiry.outside_sales_owners.map {|s| {"label": s.full_name, "value": s.id.to_s}}.as_json
                       else
                         Inquiry.procurement_specialists.map {|s| {"label": s.full_name, "value": s.id.to_s}}.as_json
                       end,
                       if @category.present? && @category == 'company_key'
                         [{"source": autocomplete_overseers_accounts_path}]
                       end,
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

json.recordsTotal @indexed_kra_reports.count
json.recordsFiltered @indexed_kra_reports.total_count
json.draw params[:draw]
