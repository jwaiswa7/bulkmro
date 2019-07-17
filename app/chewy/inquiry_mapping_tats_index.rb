class InquiryMappingTatsIndex < BaseIndex
  define_type InquiryMappingTat.with_includes do
    field :id, type: 'integer'
    field :inquiry_number, value: -> (record) {record.inquiry.inquiry_number.to_i}, type: 'integer'
    field :inquiry_number_string, value: -> (record) {record.inquiry.inquiry_number.to_s}, analyzer: 'substring'
    field :inquiry_created_at, value: -> (record) {record.inquiry.created_at}, type: 'date'
    field :inquiry_products, value: -> (record) {record.inquiry.products.count}, type: 'integer'
    field :inside_sales_owner_id, value: -> (record) {record.inquiry.inside_sales_owner.id if record.inquiry.inside_sales_owner.present?}, type: 'integer'
    field :inside_sales_owner, value: -> (record) {record.inquiry.inside_sales_owner.to_s}, analyzer: 'substring'

    field :sales_quote, value: -> (record) {record.sales_quote_id if record.sales_quote_id.present?}, type: 'integer'
    field :so_doc_id, value: -> (record) {record.sales_order_id if record.sales_order.present?}, type: 'integer'

    field :sales_order_number, value: -> (record) {record.sales_order.order_number if record.sales_order.present?}, type: 'long'
    field :sales_order_status, value: -> (record) {record.sales_order.status if record.sales_order.present?}, analyzer: 'substring'

    field :inside_sales_executive, value: -> (record) {record.inquiry.inside_sales_owner_id}
    field :outside_sales_executive, value: -> (record) {record.inquiry.outside_sales_owner_id}
    field :procurement_operations, value: -> (record) {record.inquiry.procurement_operations_id}

    field :time_new_inquiry, value: -> (record) {record.inquiry.inquiry_status_records.find_by(status: 'New Inquiry').created_at if record.inquiry.inquiry_status_records.present? && record.inquiry.inquiry_status_records.find_by(status: 'New Inquiry').present?}, type: 'date'

    field :status_acknowledgment_mail, value: -> (record) {InquiryStatusRecord.turn_around_time(record.inquiry_id, 'Inquiry', record.inquiry_id, 'Acknowledgement Mail')}, type: 'integer'
    field :time_acknowledgment_mail, value: -> (record) {InquiryStatusRecord.tat_created_at(record.inquiry_id, 'Inquiry', record.inquiry_id, 'Acknowledgement Mail')}, analyzer: 'substring', fielddata: true

    field :status_cross_reference, value: -> (record) {InquiryStatusRecord.turn_around_time(record.inquiry_id, 'Inquiry', record.inquiry_id, 'Cross Reference')}, type: 'integer'
    field :time_cross_reference, value: -> (record) {InquiryStatusRecord.tat_created_at(record.inquiry_id, 'Inquiry', record.inquiry_id, 'Cross Reference')}, analyzer: 'substring', fielddata: true

    field :status_preparing_quotation, value: -> (record) {InquiryStatusRecord.turn_around_time(record.inquiry_id, 'SalesQuote', record.sales_quote_id, 'Preparing Quotation')}, type: 'integer'
    field :time_preparing_quotation, value: -> (record) {InquiryStatusRecord.tat_created_at(record.inquiry_id, 'SalesQuote', record.sales_quote_id, 'Preparing Quotation')}, analyzer: 'substring', fielddata: true

    field :status_quotation_sent, value: -> (record) {InquiryStatusRecord.turn_around_time(record.inquiry_id, 'SalesQuote', record.sales_quote_id, 'Quotation Sent')}, type: 'integer'
    field :time_quotation_sent, value: -> (record) {InquiryStatusRecord.tat_created_at(record.inquiry_id, 'SalesQuote', record.sales_quote_id, 'Quotation Sent')}, analyzer: 'substring', fielddata: true

    field :status_draft_so_appr_by_sales_manager, value: -> (record) {InquiryStatusRecord.turn_around_time(record.inquiry_id, 'SalesOrder', record.sales_order_id, 'Draft SO for Approval by Sales Manager')}, type: 'integer'
    field :time_draft_so_appr_by_sales_manager, value: -> (record) {InquiryStatusRecord.tat_created_at(record.inquiry_id, 'SalesOrder', record.sales_order_id, 'Draft SO for Approval by Sales Manager')}, analyzer: 'substring'

    field :status_so_reject_by_sales_manager, value: -> (record) {InquiryStatusRecord.turn_around_time(record.inquiry_id, 'SalesOrder', record.sales_order_id, 'SO Rejected by Sales Manager')}, type: 'integer'
    field :time_so_reject_by_sales_manager, value: -> (record) {InquiryStatusRecord.tat_created_at(record.inquiry_id, 'SalesOrder', record.sales_order_id, 'SO Rejected by Sales Manager')}, analyzer: 'substring'

    field :status_so_draft_pending_acct_approval, value: -> (record) {InquiryStatusRecord.turn_around_time(record.inquiry_id, 'SalesOrder', record.sales_order_id, 'SO Draft: Pending Accounts Approval')}, type: 'integer'
    field :time_so_draft_pending_acct_approval, value: -> (record) {InquiryStatusRecord.tat_created_at(record.inquiry_id, 'SalesOrder', record.sales_order_id, 'SO Draft: Pending Accounts Approval')}, analyzer: 'substring'

    field :status_rejected_by_accounts, value: -> (record) {InquiryStatusRecord.turn_around_time(record.inquiry_id, 'SalesOrder', record.sales_order_id, 'Rejected by Accounts')}, type: 'integer'
    field :time_rejected_by_accounts, value: -> (record) {InquiryStatusRecord.tat_created_at(record.inquiry_id, 'SalesOrder', record.sales_order_id, 'Rejected by Accounts')}, analyzer: 'substring'

    field :status_hold_by_accounts, value: -> (record) {InquiryStatusRecord.turn_around_time(record.inquiry_id, 'SalesOrder', record.sales_order_id, 'Hold by Accounts')}, type: 'integer'
    field :time_hold_by_accounts, value: -> (record) {InquiryStatusRecord.tat_created_at(record.inquiry_id, 'SalesOrder', record.sales_order_id, 'Hold by Accounts')}, analyzer: 'substring'

    field :status_order_won, value: -> (record) {InquiryStatusRecord.turn_around_time(record.inquiry_id, 'SalesOrder', record.sales_order_id, 'Order Won')}, type: 'integer'
    field :time_order_won, value: -> (record) {InquiryStatusRecord.tat_created_at(record.inquiry_id, 'SalesOrder', record.sales_order_id, 'Order Won')}, analyzer: 'substring', fielddata: true

    field :status_order_lost, value: -> (record) {InquiryStatusRecord.turn_around_time(record.inquiry_id, 'Inquiry', record.sales_order_id, 'Order Lost')}, type: 'integer'
    field :time_order_lost, value: -> (record) {InquiryStatusRecord.tat_created_at(record.inquiry_id, 'Inquiry', record.sales_order_id, 'Order Lost')}, analyzer: 'substring'

    field :status_regret, value: -> (record) {InquiryStatusRecord.turn_around_time(record.inquiry_id, 'Inquiry', record.sales_order_id, 'Regret')}, type: 'integer'
    field :time_regret, value: -> (record) {InquiryStatusRecord.tat_created_at(record.inquiry_id, 'Inquiry', record.sales_order_id, 'Regret')}, analyzer: 'substring'

    field :created_at, value: -> (record) {record.inquiry.created_at}, type: 'date'
  end
end
