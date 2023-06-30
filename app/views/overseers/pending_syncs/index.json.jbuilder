json.data (@inquiries) do |inquiry|
    json.array! [
                    [
                        row_action_button_without_fa(overseers_pending_sync_resync_path(inquiry), 'bmro-icon-table fal fa-retweet-alt', 'Resync Inquiry Order', 'danger'), 
                        row_action_button_without_fa(overseers_pending_sync_resync_urgent_path(inquiry), 'bmro-icon-table bmro-icon-refresh', 'Resync Urgent', 'danger')
                    ],
                    inquiry.inquiry_number,
                    status_badge(inquiry.status), 
                    link_to(inquiry.account.to_s, overseers_account_path(inquiry.account), target: '_blank'),
                    link_to(inquiry.company.to_s, overseers_company_path(inquiry.company), target: '_blank'),
                    format_succinct_date(inquiry.created_at),
                ]
  end
  
  json.recordsTotal @inquiries.count
  json.recordsFiltered @inquiries.total_count
  json.draw params[:draw]