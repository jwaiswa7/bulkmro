

class InquiryStatusRecord < ApplicationRecord
  belongs_to :subject, polymorphic: true, required: false

  enum status: {
      'New Inquiry': 0,
      'Acknowledgement Mail': 2,
      'Cross Reference': 3,
      'Preparing Quotation': 4,
      'Quotation Sent': 5,
      'Follow Up on Quotation': 6,
      'Expected Order': 7,
      'SO Draft: Pending Accounts Approval': 8,
      'Order Lost': 9,
      'Regret': 10,
      'Lead by O/S': 11,
      'Supplier RFQ Sent': 12,
      'SO Not Created-Customer PO Awaited': 13,
      'SO Not Created-Pending Customer PO Revision': 14,
      'Draft SO for Approval by Sales Manager': 15,
      'SO Rejected by Sales Manager': 17,
      'Order Won': 18,
      'Rejected by Accounts': 19,
      'Hold by Accounts': 20,
      'SAP Rejected': 21
  }

  enum remote_uid: {
      'New Inquiry': 1,
      'Acknowledgement Mail': 2,
      'Cross Reference': 3,
      'Preparing Quotation': 5,
      'Quotation Sent': 6,
      'Follow Up on Quotation': 7,
      'Expected Order': 8,
      'Order Won': 12,
      'Order Lost': 15,
      'Regret': 16,
      'Lead by O/S': 99,
      'Supplier RFQ Sent': 4,
      'Draft SO for Approval by Sales Manager': 9,
      'SO Rejected by Sales Manager': 10,
      'Rejected by Accounts': 12,
      'Hold by Accounts': 23,
      'SAP Rejected': 24
  }, _prefix: true

  def color
    if self.subject.present?
      if self.subject_type == 'SalesOrder'
        'warning'
      else
        'warning'
      end

    else
      'warning'
    end
  end

  belongs_to :inquiry
end
