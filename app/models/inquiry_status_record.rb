require 'action_view'
class InquiryStatusRecord < ApplicationRecord
  include ActionView::Helpers::DateHelper
  belongs_to :subject, polymorphic: true, required: false
  belongs_to :parent, polymorphic: true, foreign_key: 'parent_id', required: false
  belongs_to :previous_status_record, class_name: 'InquiryStatusRecord', foreign_key: 'previous_status_record_id', required: false

  scope :last_inquiry, -> { where(subject_type: 'Inquiry').last.subject }
  scope :not_expected_order, -> { where.not(status: 'Expected Order') }
  scope :valid_status_records, -> { where.not(id: InquiryStatusRecord.where(subject_type: 'Inquiry', status: ['Preparing Quotation', 'Quotation Sent', 'Rejected by Accounts'])) }

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
      'RFQ Sent': 12,
      'SO Not Created-Customer PO Awaited': 13,
      'SO Not Created-Pending Customer PO Revision': 14,
      'Draft SO for Approval by Sales Manager': 15,
      'SO Rejected by Sales Manager': 17,
      'Order Won': 18,
      'Rejected by Accounts': 19,
      'Hold by Accounts': 20,
      'SAP Rejected': 21,
      'Regret Request': 22,
      'PQ Received': 23,
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
      'RFQ Sent': 4,
      'Draft SO for Approval by Sales Manager': 9,
      'SO Rejected by Sales Manager': 10,
      'Rejected by Accounts': 12,
      'Hold by Accounts': 23,
      'SAP Rejected': 24
  }, _prefix: true

  after_create :save_inquiry_mapping_tat_record

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

  def fetch_previous_status_record
    parent_record = parent
    if parent_record.blank?
      service = Services::Overseers::Inquiries::InquiryPreviousStatusRecord.new(self)
      parent_record = service.call
    end
    parent_record
  end

  # def tat
  #   previous_status_record.present? ? (((self.created_at.to_time.to_i - previous_status_record.created_at.to_time.to_i) / 60.0).ceil.abs) : '-'
  # end

  def save_inquiry_mapping_tat_record
    InquiryMappingTat.save_record(self.inquiry, self.subject)
  end

  def calculate_turn_around_time(previous_status)
    prev_status_time = previous_status.present? ? previous_status.created_at.to_time.to_i : 0
    current_status_time = self.created_at
    minutes = ((current_status_time.to_time.to_i - prev_status_time) / 60.0).ceil.abs
    minutes
  end

  def self.tat_created_at(inquiry_id, type, subject_id, status)
    record = InquiryStatusRecord.where(inquiry_id: inquiry_id, subject_id: subject_id, subject_type: type, status: status).last
    record.created_at if record.present?
  end

  def self.turn_around_time(inquiry_id, type, subject_id, status)
    if status == 'Order Won'
      subject_id = (type == 'Inquiry') ? inquiry_id : subject_id
      type = ['Inquiry', 'SalesOrder']
    end
    record = InquiryStatusRecord.where(inquiry_id: inquiry_id, subject_id: subject_id, subject_type: type, status: status).last
    record.tat_minutes if record.present?
  end

  belongs_to :inquiry
end
