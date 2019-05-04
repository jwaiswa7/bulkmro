class InquiryMappingTat < ApplicationRecord

  update_index('inquiry_mapping_tats#inquiry_mapping_tat') { self }

  attr_accessor :inside_sales_owner

  belongs_to :inquiry
  belongs_to :sales_quote, required: false
  belongs_to :sales_order, required: false


  scope :with_includes, -> { includes(:inquiry, inquiry: [:inquiry_status_records]) }

  def self.save_record(inquiry, subject)
    if subject.class.name == 'SalesOrder'
      record = InquiryMappingTat.where(inquiry_id: inquiry.id, sales_quote_id: subject.sales_quote.id, sales_order_id: nil).first
      if record.present?
        record.update_attributes(sales_order_id: subject.id)
      else
        InquiryMappingTat.where(inquiry_id: inquiry.id, sales_order_id: subject.id, sales_quote_id: subject.sales_quote.id, inquiry_created_at: inquiry.created_at).create
      end
    elsif subject.class.name == 'SalesQuote'
      record = InquiryMappingTat.where(inquiry_id: inquiry.id, sales_quote_id: nil).first
      if record.present?
        record.update_attributes(sales_quote_id: subject.id)
      else
        InquiryMappingTat.where(inquiry_id: inquiry.id, sales_quote_id: subject.id, inquiry_created_at: inquiry.created_at).create
      end
    else
      InquiryMappingTat.where(inquiry_id: inquiry.id, inquiry_created_at: inquiry.created_at).first_or_create
    end
  end

  def calculate_turn_around_time(current_status)
    current_record = self.inquiry.inquiry_status_records.find_by(status: current_status)
    prev_status = current_record.previous_status_record
    prev_status_time = prev_status.present? ? prev_status.created_at.to_time.to_i : 0
    current_status_time = current_record.created_at

    minutes = ((current_status_time.to_time.to_i - prev_status_time) / 60.0).ceil.abs
    tat = minutes
    tat
  end
end
