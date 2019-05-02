class Services::Shared::Migrations::AddInquiryMappingTat < Services::Shared::Migrations::Migrations
  def call
    # add date range
    InquiryMappingTat.destroy_all
    start_date = Date.parse('01-01-2019')
    end_date = Date.today
    inquiries = Inquiry.where(created_at: start_date..end_date).where.not(status: 'Expected Order').includes(:sales_orders)
    Chewy.strategy(:bypass) do
      inquiries.each do |inquiry|
        if inquiry.sales_orders.present?
          inquiry.sales_orders.each do |sales_order|
            InquiryMappingTat.where(inquiry_id: inquiry.id, sales_order_id: sales_order.id, sales_quote_id: sales_order.sales_quote.id, inquiry_created_at: inquiry.created_at).first_or_create
          end
          inquiry.sales_quotes.each do |sales_quote|
            InquiryMappingTat.where(inquiry_id: inquiry.id, sales_quote_id: sales_quote.id, inquiry_created_at: inquiry.created_at).first_or_create
          end
        elsif inquiry.sales_quotes.present?
          inquiry.sales_quotes.each do |sales_quote|
            InquiryMappingTat.where(inquiry_id: inquiry.id, sales_quote_id: sales_quote.id, inquiry_created_at: inquiry.created_at).first_or_create
          end
        else
          InquiryMappingTat.where(inquiry_id: inquiry.id, inquiry_created_at: inquiry.created_at).first_or_create
        end
      end
    end
  end
end
