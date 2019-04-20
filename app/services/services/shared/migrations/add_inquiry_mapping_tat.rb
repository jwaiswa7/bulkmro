class Services::Shared::Migrations::AddInquiryMappingTat < Services::Shared::Migrations::Migrations
  def call
    inquiries = Inquiry.where.not(status: 'Expected Order').includes(:sales_orders)
    inquiries.each do |inquiry|
      if inquiry.sales_orders.present?
        inquiry.sales_orders.each do |sales_order|
          InquiryMappingTat.where(inquiry_id: inquiry.id, sales_order_id: sales_order.id, sales_quote_id: sales_order.sales_quote.id).first_or_create
        end
        inquiry.sales_quotes.each do |sales_quote|
          InquiryMappingTat.where(inquiry_id: inquiry.id, sales_quote_id: sales_quote.id).first_or_create
        end
      elsif inquiry.sales_quotes.present?
        inquiry.sales_quotes.each do |sales_quote|
          InquiryMappingTat.where(inquiry_id: inquiry.id, sales_quote_id: sales_quote.id).first_or_create
        end
      else
        InquiryMappingTat.where(inquiry_id: inquiry.id).first_or_create
      end
    end
  end

end

