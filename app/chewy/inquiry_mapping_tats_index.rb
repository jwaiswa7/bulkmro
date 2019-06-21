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

    field :inside_sales_executive, value: -> (record) { record.inquiry.inside_sales_owner_id }
    field :outside_sales_executive, value: -> (record) { record.inquiry.outside_sales_owner_id }
    field :procurement_operations, value: -> (record) { record.inquiry.procurement_operations_id }

    field :time_new_inquiry, value: -> (record) {record.inquiry.inquiry_status_records.find_by(status: 'New Inquiry').created_at if record.inquiry.inquiry_status_records.present? && record.inquiry.inquiry_status_records.find_by(status: 'New Inquiry').present?}, type: 'date'

    field :status_acknowledgment_mail, value: -> (record) {record.calculate_turn_around_time('Acknowledgement Mail') if record.inquiry.inquiry_status_records.present? && record.inquiry.inquiry_status_records.where(status: 'Acknowledgement Mail').present?}, type: 'integer'
    field :time_acknowledgment_mail, value: -> (record) {record.inquiry.inquiry_status_records.find_by(status: 'Acknowledgement Mail').created_at if record.inquiry.inquiry_status_records.present? && record.inquiry.inquiry_status_records.find_by(status: 'Acknowledgement Mail').present?}, analyzer: 'substring', fielddata: true

    field :status_cross_reference, value: -> (record) {record.calculate_turn_around_time('Cross Reference') if record.inquiry.inquiry_status_records.present? && record.inquiry.inquiry_status_records.where(status: 'Cross Reference').present?}, type: 'integer'
    field :time_cross_reference, value: -> (record) {record.inquiry.inquiry_status_records.find_by(status: 'Cross Reference').created_at if record.inquiry.inquiry_status_records.present? && record.inquiry.inquiry_status_records.find_by(status: 'Cross Reference').present?}, analyzer: 'substring', fielddata: true

    field :status_preparing_quotation, value: -> (record) {record.calculate_turn_around_time('Preparing Quotation') if record.inquiry.inquiry_status_records.present? && record.inquiry.inquiry_status_records.where(status: 'Preparing Quotation').present?}, type: 'integer'
    field :time_preparing_quotation, value: -> (record) {record.inquiry.inquiry_status_records.find_by(status: 'Preparing Quotation').created_at if record.inquiry.inquiry_status_records.present? && record.inquiry.inquiry_status_records.find_by(status: 'Preparing Quotation').present?}, analyzer: 'substring', fielddata: true

    field :status_quotation_sent, value: -> (record) {record.calculate_turn_around_time('Quotation Sent') if record.inquiry.inquiry_status_records.present? && record.inquiry.inquiry_status_records.where(status: 'Quotation Sent').present?}, type: 'integer'
    field :time_quotation_sent, value: -> (record) {record.inquiry.inquiry_status_records.find_by(status: 'Quotation Sent').created_at if record.inquiry.inquiry_status_records.present? && record.inquiry.inquiry_status_records.find_by(status: 'Quotation Sent').present?}, analyzer: 'substring', fielddata: true

    field :status_draft_so_appr_by_sales_manager, value: -> (record) {record.calculate_turn_around_time('Draft SO for Approval by Sales Manager') if record.inquiry.inquiry_status_records.present? && record.inquiry.inquiry_status_records.where(status: 'Draft SO for Approval by Sales Manager').present?}, type: 'integer'
    field :time_draft_so_appr_by_sales_manager, value: -> (record) {record.inquiry.inquiry_status_records.find_by(status: 'Draft SO for Approval by Sales Manager').created_at if record.inquiry.inquiry_status_records.present? && record.inquiry.inquiry_status_records.find_by(status: 'Draft SO for Approval by Sales Manager').present?}, analyzer: 'substring'

    field :status_so_reject_by_sales_manager, value: -> (record) {record.calculate_turn_around_time('SO Rejected by Sales Manager') if record.inquiry.inquiry_status_records.present? && record.inquiry.inquiry_status_records.where(status: 'SO Rejected by Sales Manager').present?}, type: 'integer'
    field :time_so_reject_by_sales_manager, value: -> (record) {record.inquiry.inquiry_status_records.find_by(status: 'SO Rejected by Sales Manager').created_at if record.inquiry.inquiry_status_records.present? && record.inquiry.inquiry_status_records.find_by(status: 'SO Rejected by Sales Manager').present?}, analyzer: 'substring'

    field :status_so_draft_pending_acct_approval, value: -> (record) {record.calculate_turn_around_time('SO Draft: Pending Accounts Approval') if record.inquiry.inquiry_status_records.present? && record.inquiry.inquiry_status_records.where(status: 'SO Draft: Pending Accounts Approval').present?}, type: 'integer'
    field :time_so_draft_pending_acct_approval, value: -> (record) {record.inquiry.inquiry_status_records.find_by(status: 'SO Draft: Pending Accounts Approval').created_at if record.inquiry.inquiry_status_records.present? && record.inquiry.inquiry_status_records.find_by(status: 'SO Draft: Pending Accounts Approval').present?}, analyzer: 'substring'

    field :status_rejected_by_accounts, value: -> (record) {record.calculate_turn_around_time('Rejected by Accounts') if record.inquiry.inquiry_status_records.present? && record.inquiry.inquiry_status_records.where(status: 'Rejected by Accounts').present?}, type: 'integer'
    field :time_rejected_by_accounts, value: -> (record) {record.inquiry.inquiry_status_records.find_by(status: 'Rejected by Accounts').created_at if record.inquiry.inquiry_status_records.present? && record.inquiry.inquiry_status_records.find_by(status: 'Rejected by Accounts').present?}, analyzer: 'substring'

    field :status_hold_by_accounts, value: -> (record) {record.calculate_turn_around_time('Hold by Accounts') if record.inquiry.inquiry_status_records.present? && record.inquiry.inquiry_status_records.where(status: 'Hold by Accounts').present?}, type: 'integer'
    field :time_hold_by_accounts, value: -> (record) {record.inquiry.inquiry_status_records.find_by(status: 'Hold by Accounts').created_at if record.inquiry.inquiry_status_records.present? && record.inquiry.inquiry_status_records.find_by(status: 'Hold by Accounts').present?}, analyzer: 'substring'

    field :status_order_won, value: -> (record) {record.calculate_turn_around_time('Order Won') if record.inquiry.inquiry_status_records.present? && record.inquiry.inquiry_status_records.where(status: 'Order Won').present?}, type: 'integer'
    field :time_order_won, value: -> (record) {record.inquiry.inquiry_status_records.find_by(status: 'Order Won').created_at if record.inquiry.inquiry_status_records.present? && record.inquiry.inquiry_status_records.find_by(status: 'Order Won').present?}, analyzer: 'substring', fielddata: true

    field :status_order_lost, value: -> (record) {record.calculate_turn_around_time('Order Lost') if record.inquiry.inquiry_status_records.present? && record.inquiry.inquiry_status_records.where(status: 'Order Lost').present?}, type: 'integer'
    field :time_order_lost, value: -> (record) {record.inquiry.inquiry_status_records.find_by(status: 'Order Lost').created_at if record.inquiry.inquiry_status_records.present? && record.inquiry.inquiry_status_records.find_by(status: 'Order Lost').present?}, analyzer: 'substring'

    field :status_regret, value: -> (record) {record.calculate_turn_around_time('Regret') if record.inquiry.inquiry_status_records.present? && record.inquiry.inquiry_status_records.where(status: 'Regret').present?}, type: 'integer'
    field :time_regret, value: -> (record) {record.inquiry.inquiry_status_records.find_by(status: 'Regret').created_at if record.inquiry.inquiry_status_records.present? && record.inquiry.inquiry_status_records.find_by(status: 'Regret').present?}, analyzer: 'substring'
    field :created_at, value: -> (record) {record.inquiry.created_at}, type: 'date'
  end
end
