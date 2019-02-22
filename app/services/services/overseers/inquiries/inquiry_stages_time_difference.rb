require 'action_view'
class Services::Overseers::Inquiries::InquiryStagesTimeDifference < Services::Shared::BaseService
  include ActionView::Helpers::DateHelper

  def initialize(status_record)
    @status_record = status_record
  end

  def call

    tat_array = []
    records = InquiryStatusRecord.where('status < ?', Inquiry.statuses[status_record.status]).where('created_at < ?', status_record.created_at).order(created_at: :desc)
    record = if records.where(subject: status_record.subject).any?
               records.where(subject: status_record.subject).first
             elsif status_record.subject_type == "SalesOrder" && records.where(subject: status_record.subject.sales_quote).any?
               records.where(subject: status_record.subject.sales_quote).first
             else
               records.first
             end
    if record.present?
      time_difference = distance_of_time_in_words(status_record.created_at, record.created_at, {})
      tat_array << ["#{status_record.subject} ##{status_record.subject_id}", status_record.status, record.status, time_difference]
    end
    return tat_array
  end

  private

  attr_accessor :status_record

end
# Inquiry.statuses.sort_by {|key, value| value}.to_h
# Inquiry.statuses.sort_by {|key, value| value}.reverse.to_h
# sorted_statuses.map do |status, value|
#   sorted_statuses.delete(status) unless records.pluck(:status).include?(status)
# end
# {"New Inquiry"=>0, "Acknowledgement Mail"=>2, "Cross Reference"=>3, "Preparing Quotation"=>4, "Quotation Sent"=>5, "Follow Up on Quotation"=>6, "Expected Order"=>7, "SO Draft: Pending Accounts Approval"=>8, "Order Lost"=>9, "Regret"=>10, "Lead by O/S"=>11, "Supplier RFQ Sent"=>12, "SO Not Created-Customer PO Awaited"=>13, "SO Not Created-Pending Customer PO Revision"=>14, "Draft SO for Approval by Sales Manager"=>15, "SO Rejected by Sales Manager"=>17, "Order Won"=>18, "Rejected by Accounts"=>19, "Hold by Accounts"=>20}
#
# {"Hold by Accounts"=>20, "Rejected by Accounts"=>19, "Order Won"=>18, "SO Rejected by Sales Manager"=>17, "Draft SO for Approval by Sales Manager"=>15, "SO Not Created-Pending Customer PO Revision"=>14, "SO Not Created-Customer PO Awaited"=>13, "Supplier RFQ Sent"=>12, "Lead by O/S"=>11, "Regret"=>10, "Order Lost"=>9, "SO Draft: Pending Accounts Approval"=>8, "Expected Order"=>7, "Follow Up on Quotation"=>6, "Quotation Sent"=>5, "Preparing Quotation"=>4, "Cross Reference"=>3, "Acknowledgement Mail"=>2, "New Inquiry"=>0}