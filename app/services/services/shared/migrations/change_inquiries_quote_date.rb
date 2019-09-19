class Services::Shared::Migrations::ChangeInquiriesQuoteDate < Services::Shared::Migrations::Migrations

  def call
    @inquiries_number = [38908, 38905, 38753, 38725, 38723, 38721, 38716, 38714, 38713, 38712, 38708, 38707, 38706, 38704, 38703, 38670, 38450, 38411, 38223, 38104, 27463, 25518, 25418, 25127, 25128, 21414, 21131, 20898, 20897, 20896, 20894, 20893, 20895, 20899, 20504, 20137, 20138, 19908, 19880, 19807, 19243]
    @missing_inquiry = []
    inquiries_number.each do |inq|
      @inquiry = Inquiry.find_by_inquiry_number(inq)
      if inquiry.blank?
        missing_inquiry << inq
      else
        final_sales_quote = inquiry.final_sales_quote
        if final_sales_quote.present?
          puts "Quotation Date is updated for #{inquiry} from #{inquiry.quotation_date} to #{final_sales_quote.created_at}"
          inquiry.update_attributes(quotation_date: final_sales_quote.created_at)
        else
          puts "Quotation Date is updated for #{inquiry} from #{inquiry.quotation_date} to ''"
          inquiry.update_attributes(quotation_date: "")
        end
      end
    end
  end
  attr_accessor :inquiries_number, :missing_inquiry, :inquiry
end