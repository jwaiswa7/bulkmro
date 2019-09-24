class InquiryMappingTatsIndex < BaseIndex
  start_date = Date.parse('01-01-2019')
  end_date = Date.today.end_of_day
  define_type InquiryMappingTat.where(inquiry_created_at: start_date..end_date).with_includes do
    field :id, type: 'integer'
    field :inquiry_number, value: -> (record) { record.inquiry.inquiry_number.to_i }, type: 'integer'
    field :inquiry_number_string, value: -> (record) { record.inquiry.inquiry_number.to_s }, analyzer: 'substring'
    field :inquiry_created_at, value: -> (record) { record.inquiry.created_at }, type: 'date'
    field :inquiry_products, value: -> (record) { record.inquiry.products.count }, type: 'integer'
    field :inside_sales_owner_id, value: -> (record) { record.inquiry.inside_sales_owner.id if record.inquiry.inside_sales_owner.present? }, type: 'integer'
    field :inside_sales_owner, value: -> (record) { record.inquiry.inside_sales_owner.to_s }, analyzer: 'substring'

    field :sales_quote, value: -> (record) { record.sales_quote_id if record.sales_quote_id.present? }, type: 'integer'
    field :so_doc_id, value: -> (record) { record.sales_order_id if record.sales_order.present? }, type: 'integer'

    field :sales_order_number, value: -> (record) { record.sales_order.order_number if record.sales_order.present? }, type: 'long'
    field :sales_order_status, value: -> (record) { record.sales_order.status if record.sales_order.present? }, analyzer: 'substring'

    field :inside_sales_executive, value: -> (record) { record.inquiry.inside_sales_owner_id }
    field :outside_sales_executive, value: -> (record) { record.inquiry.outside_sales_owner_id }
    field :procurement_operations, value: -> (record) { record.inquiry.procurement_operations_id }

    field :time_new_inquiry, value: -> (record) { record.inquiry.inquiry_status_records.find_by(status: 'New Inquiry').created_at if record.inquiry.inquiry_status_records.present? && record.inquiry.inquiry_status_records.find_by(status: 'New Inquiry').present? }, type: 'date'

    field :acknowledgment_mail_date, value: -> (record) { InquiryStatusRecord.tat_created_at(record.inquiry_id, 'Inquiry', record.inquiry_id, 'Acknowledgement Mail') }, type: 'date'
    field :acknowledgment_mail_mins, value: -> (record) { InquiryStatusRecord.turn_around_time(record.inquiry_id, 'Inquiry', record.inquiry_id, 'Acknowledgement Mail') }, type: 'integer'

    field :cross_reference_date, value: -> (record) { InquiryStatusRecord.tat_created_at(record.inquiry_id, 'Inquiry', record.inquiry_id, 'Cross Reference') }, type: 'date'
    field :cross_reference_mins, value: -> (record) { InquiryStatusRecord.turn_around_time(record.inquiry_id, 'Inquiry', record.inquiry_id, 'Cross Reference') }, type: 'integer'

    field :preparing_quotation_date, value: -> (record) { InquiryStatusRecord.tat_created_at(record.inquiry_id, 'SalesQuote', record.sales_quote_id, 'Preparing Quotation') }, type: 'date'
    field :preparing_quotation_mins, value: -> (record) { InquiryStatusRecord.turn_around_time(record.inquiry_id, 'SalesQuote', record.sales_quote_id, 'Preparing Quotation') }, type: 'integer'

    field :quotation_sent_date, value: -> (record) { InquiryStatusRecord.tat_created_at(record.inquiry_id, 'SalesQuote', record.sales_quote_id, 'Quotation Sent') }, type: 'date'
    field :quotation_sent_mins, value: -> (record) { InquiryStatusRecord.turn_around_time(record.inquiry_id, 'SalesQuote', record.sales_quote_id, 'Quotation Sent') }, type: 'integer'

    field :draft_so_appr_by_sales_manager_date, value: -> (record) { InquiryStatusRecord.tat_created_at(record.inquiry_id, 'SalesOrder', record.sales_order_id, 'Draft SO for Approval by Sales Manager') }, type: 'date'
    field :draft_so_appr_by_sales_manager_mins, value: -> (record) { InquiryStatusRecord.turn_around_time(record.inquiry_id, 'SalesOrder', record.sales_order_id, 'Draft SO for Approval by Sales Manager') }, type: 'integer'

    field :so_reject_by_sales_manager_date, value: -> (record) { InquiryStatusRecord.tat_created_at(record.inquiry_id, 'SalesOrder', record.sales_order_id, 'SO Rejected by Sales Manager') }, type: 'date'
    field :so_reject_by_sales_manager_mins, value: -> (record) { InquiryStatusRecord.turn_around_time(record.inquiry_id, 'SalesOrder', record.sales_order_id, 'SO Rejected by Sales Manager') }, type: 'integer'

    field :so_draft_pending_acct_approval_date, value: -> (record) { InquiryStatusRecord.tat_created_at(record.inquiry_id, 'SalesOrder', record.sales_order_id, 'SO Draft: Pending Accounts Approval') }, type: 'date'
    field :so_draft_pending_acct_approval_mins, value: -> (record) { InquiryStatusRecord.turn_around_time(record.inquiry_id, 'SalesOrder', record.sales_order_id, 'SO Draft: Pending Accounts Approval') }, type: 'integer'

    field :rejected_by_accounts_date, value: -> (record) { InquiryStatusRecord.tat_created_at(record.inquiry_id, 'SalesOrder', record.sales_order_id, 'Rejected by Accounts') }, type: 'date'
    field :rejected_by_accounts_mins, value: -> (record) { InquiryStatusRecord.turn_around_time(record.inquiry_id, 'SalesOrder', record.sales_order_id, 'Rejected by Accounts') }, type: 'integer'

    field :hold_by_accounts_date, value: -> (record) { InquiryStatusRecord.tat_created_at(record.inquiry_id, 'SalesOrder', record.sales_order_id, 'Hold by Accounts') }, type: 'date'
    field :hold_by_accounts_mins, value: -> (record) { InquiryStatusRecord.turn_around_time(record.inquiry_id, 'SalesOrder', record.sales_order_id, 'Hold by Accounts') }, type: 'integer'

    field :order_won_date, value: -> (record) { InquiryStatusRecord.tat_created_at(record.inquiry_id, 'SalesOrder', record.sales_order_id, 'Order Won') }, type: 'date'
    field :order_won_mins, value: -> (record) { InquiryStatusRecord.turn_around_time(record.inquiry_id, 'SalesOrder', record.sales_order_id, 'Order Won') }, type: 'integer'

    field :order_lost_date, value: -> (record) { InquiryStatusRecord.tat_created_at(record.inquiry_id, 'Inquiry', record.sales_order_id, 'Order Lost') }, type: 'date'
    field :order_lost_mins, value: -> (record) { InquiryStatusRecord.turn_around_time(record.inquiry_id, 'Inquiry', record.sales_order_id, 'Order Lost') }, type: 'integer'

    field :regret_date, value: -> (record) { InquiryStatusRecord.tat_created_at(record.inquiry_id, 'Inquiry', record.sales_order_id, 'Regret') }, type: 'date'
    field :regret_mins, value: -> (record) { InquiryStatusRecord.turn_around_time(record.inquiry_id, 'Inquiry', record.sales_order_id, 'Regret') }, type: 'integer'

    field :created_at, value: -> (record) { record.inquiry.created_at }, type: 'date'
  end
end
