class InquiryStatusRecord < ApplicationRecord

  enum status: {
      :'New Inquiry' => 0,
      :'Acknowledgement Mail' => 2,
      :'Cross Reference' => 3,
      :'Preparing Quotation' => 4,
      :'Quotation Sent' => 5,
      :'Follow Up on Quotation' => 6,
      :'Expected Order' => 7,
      :'SO Draft: Pending Accounts Approval' => 8,
      :'Order Lost' => 9,
      :'Regret' => 10,
      :'Lead by O/S' => 11,
      :'Supplier RFQ Sent' => 12,
      :'SO Not Created-Customer PO Awaited' => 13,
      :'SO Not Created-Pending Customer PO Revision' => 14,
      :'Draft SO for Approval by Sales Manager' => 15,
      :'SO Rejected by Sales Manager' => 17,
      :'Order Won' => 18,
      :'Rejected by Accounts' => 19,
      :'Hold by Accounts' => 20,
  }

  enum remote_uid: {
      :'Inquiry No. Assigned' => 0,
      :'Acknowledgement Mail' => 2,
      :'Cross Reference' => 3,
      :'Prepare Quotation' => 4,
      :'Quotation Sent' => 5,
      :'Follow Up on Quotation' => 6,
      :'Expected Order' => 7,
      :'Won - SO Approved by Sales Manager' => 8,
      :'Order Lost' => 9,
      :'Regret' => 10,
      :'Lead by O/S' => 11,
      :'Supplier RFQ Sent' => 12,
      :'SO Rejected by Sales Manager' => 17,
      :'SO Rejected by Accounts' => 19,
      :'SO Hold By Accounts' => 20
  }, _prefix: true

  belongs_to :inquiry
end
