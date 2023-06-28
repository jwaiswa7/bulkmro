json.data (@inquiries) do |inquiry|
    json.array! [
                    [
                        'Testing'
                    ],
                    status_badge(inquiry.status), 
                    link_to(inquiry.account.to_s, overseers_account_path(inquiry.account), target: '_blank'),
                    link_to(inquiry.company.to_s, overseers_company_path(inquiry.company), target: '_blank'),
                    format_succinct_date(inquiry.created_at),
                ]
  end
  
  json.recordsTotal @inquiries.count
  json.recordsFiltered @inquiries.total_count
  json.draw params[:draw]