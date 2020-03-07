class Services::Overseers::Inquiries::InquiryPreviousStatusRecord < Services::Shared::BaseService
  def initialize(status_record)
    @status_record = status_record
  end

  def call
    stat = { 'New Inquiry' => 1, 'Acknowledgement Mail' => 2, 'Cross Reference' => 3, 'RFQ Sent' => 4, 'PQ Received' => 5, 'Preparing Quotation' => 6, 'Quotation Sent' => 7, 'Follow Up on Quotation' => 8, 'Expected Order' => 9, 'SO Not Created-Customer PO Awaited' => 10, 'SO Not Created-Pending Customer PO Revision' => 11, 'Draft SO for Approval by Sales Manager' => 12, 'SO Rejected by Sales Manager' => 13, 'SO Draft: Pending Accounts Approval' => 14, 'Rejected by Accounts' => 15, 'SAP Rejected' => 16, 'Hold by Accounts' => 17, 'Order Won' => 18, 'Order Lost' => 19, 'Regret' => 20, 'Regret Request' => 21 }
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
          elsif status_record.subject_type == 'SalesQuote' && status_record.inquiry == record.subject
            return record
          elsif status_record.subject_type == 'Inquiry' && (status_record.status == 'Order Won' || status_record.status == 'Order Lost')
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
