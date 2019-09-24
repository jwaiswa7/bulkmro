json.data (@indexed_kra_reports) do |inquiry|
  company = Company.where(id: inquiry['key']).last
  overseer = Overseer.where(id: inquiry['key']).last.try(:to_s)
  if @category.present? && (@category.include? 'by_sales_order')
    invoices = SalesInvoice.get_invoice_count(Overseer.find(inquiry['key']), params['kra_report']['date_range'])
  end
  json.array! [
                  [],
                  if @date_range.present?
                    if @category.present? && @category == 'company_key'
                      link_to(company.try(:to_s), overseers_company_path(inquiry['key']), target: '_blank')
                    elsif @category.present? && @category.include?('outside')
                      link_to(overseer, filtered_path(kra_report_per_sales_owner_overseers_inquiries_path, [filter_by_value('Outside Sales Owner', overseer, inquiry['key']), filter_by_date_range('Date+of+inquiry', @date_range)]), target: '_blank')
                    else
                      link_to(overseer, filtered_path(kra_report_per_sales_owner_overseers_inquiries_path, [filter_by_value('Inside Sales Owner', overseer, inquiry['key']), filter_by_date_range('Date+of+inquiry', @date_range)]), target: '_blank')
                    end
                  else
                    if @category.present? && @category == 'company_key'
                      link_to(company.try(:to_s), overseers_company_path(inquiry['key']), target: '_blank')
                    elsif @category.present? && @category.include?('outside')
                      link_to(overseer, filtered_path(kra_report_per_sales_owner_overseers_inquiries_path, [filter_by_value('Outside Sales Owner', overseer, inquiry['key'])]), target: '_blank')
                    else
                      link_to(overseer, filtered_path(kra_report_per_sales_owner_overseers_inquiries_path, [filter_by_value('Inside Sales Owner', overseer, inquiry['key'])]), target: '_blank')
                    end
                  end,
                  if @category.present? && @category == 'company_key'
                    link_to(company.account, overseers_account_path(company.account), target: '_blank')
                  end,
                  if @category.present? && (@category == 'outside_sales_owner_id' || @category == 'outside_by_sales_order')
                    number_with_delimiter(Overseer.find(inquiry['key']).get_monthly_target('Inquiry', params['kra_report']), delimiter: ',') || 0
                  else
                    ''
                  end,
                  number_with_delimiter(inquiry['doc_count'], delimiter: ','),
                  number_with_delimiter(inquiry['sales_quote_count']['value'].to_i, delimiter: ','),
                  number_with_delimiter(inquiry['total_quote_value']['value'].to_i, delimiter: ','),
                  number_with_delimiter(inquiry['expected_order']['value'].to_i, delimiter: ','),
                  number_with_delimiter(inquiry['total_quote_value']['value'].to_i, delimiter: ','),
                  if  @category.present? && (@category.include? 'by_sales_order')
                    number_with_delimiter(@indexed_kra_varient_reports[inquiry['key']]['sales_orders']['value'].to_i, delimiter: ',') if @indexed_kra_varient_reports[inquiry['key']].present?
                  else
                    number_with_delimiter(inquiry['sales_order_count']['value'].to_i, delimiter: ',')
                  end,
                  if @category.present? && (@category.include? 'by_sales_order')
                    number_with_delimiter(@indexed_kra_varient_reports[inquiry['key']]['total_order_value']['value'].to_i, delimiter: ',') if @indexed_kra_varient_reports[inquiry['key']].present?
                  else
                    number_with_delimiter(inquiry['total_order_value']['value'].to_i, delimiter: ',')
                  end,
                  if @category.present? && (@category.include? 'by_sales_order')
                    number_with_delimiter(@indexed_kra_varient_reports[inquiry['key']]['gross_margin_assumed']['value'].to_i, delimiter: ',') if @indexed_kra_varient_reports[inquiry['key']].present?
                  else
                    inquiry['gross_margin_assumed'].present? ? number_with_delimiter(inquiry['gross_margin_assumed']['value'].to_i, delimiter: ',') : 0
                  end,

                  if @category.present? && (@category.include? 'by_sales_order')
                    @indexed_kra_varient_reports[inquiry['key']].present? && @indexed_kra_varient_reports[inquiry['key']]['total_order_value']['value'] != 0 ? ((@indexed_kra_varient_reports[inquiry['key']]['gross_margin_assumed']['value'] / @indexed_kra_varient_reports[inquiry['key']]['total_order_value']['value']) * 100).round : 0
                  else
                    inquiry['total_order_value']['value'] != 0 ? ((inquiry['gross_margin_assumed']['value'] / inquiry['total_order_value']['value']) * 100).round : 0
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
                    params['kra_report']['date_range'].present? ? number_with_delimiter(invoices[0].to_i, delimiter: ',') : @indexed_kra_varient_reports[inquiry['key']].present? ? number_with_delimiter(@indexed_kra_varient_reports[inquiry['key']]['invoices_count']['value'].to_i, delimiter: ',') : ''
                    # number_with_delimiter(@indexed_kra_varient_reports[inquiry['key']]['invoices_count']['value'].to_i, delimiter: ',') if @indexed_kra_varient_reports[inquiry['key']].present?
                  else
                    number_with_delimiter(inquiry['invoices_count']['value'].to_i, delimiter: ',')
                  end,
                  if @category.present? && (@category.include? 'by_sales_order')
                    params['kra_report']['date_range'].present? ? number_with_delimiter(invoices[1].to_i, delimiter: ',') : @indexed_kra_varient_reports[inquiry['key']].present? ? number_with_delimiter(@indexed_kra_varient_reports[inquiry['key']]['revenue']['value'].to_i, delimiter: ',') : ''
                    # params['kra_report']['date_range'].present? ? number_with_delimiter(invoices[1].to_i, delimiter: ',') : number_with_delimiter(inquiry['revenue']['value'].to_i, delimiter: ',')
                  else
                    number_with_delimiter(inquiry['revenue']['value'].to_i, delimiter: ',')
                  end,
                  if @category.present? && (@category.include? 'by_sales_order')
                    number_with_delimiter(@indexed_kra_varient_reports[inquiry['key']]['gross_margin_actual']['value'].to_i, delimiter: ',') if @indexed_kra_varient_reports[inquiry['key']].present?
                  else
                    number_with_delimiter(inquiry['gross_margin_actual']['value'].to_i, delimiter: ',') if inquiry['gross_margin_actual'].present?
                  end,
                  if @category.present? && (@category.include? 'by_sales_order')
                    @indexed_kra_varient_reports[inquiry['key']].present? && @indexed_kra_varient_reports[inquiry['key']]['revenue']['value'] != 0 ? ((@indexed_kra_varient_reports[inquiry['key']]['gross_margin_actual']['value'] / @indexed_kra_varient_reports[inquiry['key']]['revenue']['value']) * 100).round : 0
                  else
                    inquiry['revenue']['value'] != 0 ? ((inquiry['gross_margin_actual']['value'] / inquiry['revenue']['value']) * 100).round : 0
                  end
              ]
end

json.columnFilters [
                       [],
                       if @category.present? && @category == 'company_key'
                         [{"source": autocomplete_overseers_companies_path}]
                       elsif @category.present? && @category.include?('outside')
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
json.test params
