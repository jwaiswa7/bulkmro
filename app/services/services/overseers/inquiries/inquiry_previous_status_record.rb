class Services::Overseers::Inquiries::InquiryPreviousStatusRecord < Services::Shared::BaseService
  def initialize(status_record)
    @status_record = status_record
  end

  def call
    stat = { 'Lead by O/S' => 0, 'New Inquiry' => 1, 'Acknowledgement Mail' => 2, 'Cross Reference' => 3, 'Supplier RFQ Sent' => 4, 'Preparing Quotation' => 5, 'Quotation Sent' => 6, 'Follow Up on Quotation' => 7, 'Expected Order' => 8, 'SO Not Created-Customer PO Awaited' => 9, 'SO Not Created-Pending Customer PO Revision' => 10, 'Draft SO for Approval by Sales Manager' => 11, 'SO Rejected by Sales Manager' => 12, 'SO Draft: Pending Accounts Approval' => 13, 'Rejected by Accounts' => 14, 'SAP Rejected' => 15, 'Hold by Accounts' => 16, 'Order Won' => 17, 'Order Lost' => 18, 'Regret' => 19}
    # status_records = InquiryStatusRecord.where(inquiry_id: i.id).order('id DESC')
    if status_record.present? && status_record.inquiry.inquiry_status_records.count > 1 && !(status_record.status == 'New Inquiry' && stat[status_record.status].present?)
      keys = stat.select {|key, val| val < stat[status_record.status]}.reverse_each.to_h.keys
      inner_records = InquiryStatusRecord.valid_status_records.where(inquiry_id: status_record.inquiry_id, status: keys).order('id DESC')
      if inner_records.present?
        inner_records.each do |record|
          if record.subject == status_record.subject
            return record
          elsif status_record.subject_type == 'SalesOrder' && status_record.subject.sales_quote == record.subject
            return record
          elsif status_record.subject_type == 'SalesQuote' && status_record.subject.inquiry == record.subject
            return record

          end
        end
        return nil
      else
        return nil
      end
    else
      return nil
    end
  end

  private

    attr_accessor :status_record
end
