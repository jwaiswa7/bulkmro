class InquiryMappingTat < ApplicationRecord
  update_index('inquiry_mapping_tats') { self }

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
        InquiryMappingTat.where(inquiry_id: inquiry.id, sales_order_id: subject.id, sales_quote_id: subject.sales_quote.id, inquiry_created_at: inquiry.created_at).first_or_create
      end
    elsif subject.class.name == 'SalesQuote'
      record = InquiryMappingTat.where(inquiry_id: inquiry.id, sales_quote_id: nil).first
      if record.present?
        record.update_attributes(sales_quote_id: subject.id)
      else
        InquiryMappingTat.where(inquiry_id: inquiry.id, sales_quote_id: subject.id, inquiry_created_at: inquiry.created_at).first_or_create
      end
    else
      InquiryMappingTat.where(inquiry_id: inquiry.id, inquiry_created_at: inquiry.created_at).first_or_create
    end
  end
end
