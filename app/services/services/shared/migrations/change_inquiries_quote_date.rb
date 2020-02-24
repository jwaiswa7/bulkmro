class Services::Shared::Migrations::ChangeInquiriesQuoteDate < Services::Shared::Migrations::Migrations

  def call
    @inquiries_number = [ 39024, 39000, 38908, 38905, 38753, 38725, 38723, 38721, 38716, 38714, 38713, 38712, 38708, 38707, 38706, 38704, 38703, 38670, 38450, 38411, 38223, 38104, 27463, 25518, 25418, 25127, 25128, 21414, 21131, 20897, 20898, 20894, 20896, 20899, 20895, 20893, 20504, 20137, 20138, 19908, 19880, 19807, 19243]
    @missing_inquiry = []
    @inquiry_present = []
    inquiries_number.each do |inq|
      @inquiry = Inquiry.find_by_inquiry_number(inq)
      if inquiry.blank?
        missing_inquiry << inq
      else
        final_sales_quote = inquiry.final_sales_quote
        inquiry_present << inq
        if final_sales_quote.present?
          puts "Quotation Date is updated for #{inquiry} from #{inquiry.quotation_date} to #{final_sales_quote.created_at}"
          inquiry.quotation_date = final_sales_quote.created_at
        else
          puts "Quotation Date is updated for #{inquiry} from #{inquiry.quotation_date} to ''"
          inquiry.quotation_date = ""
        end
        inquiry.save(validate: false)
      end
    end
  end

  def download_inquiry_export
    service = "#{Rails.root}/tmp/tax_rate_script_issues.csv"
    headers = ['Inquiry', 'Created At', 'Sales Quote Date']
    @inquiries_number = [ 39024, 39000, 38908, 38905, 38753, 38725, 38723, 38721, 38716, 38714, 38713, 38712, 38708, 38707, 38706, 38704, 38703, 38670, 38450, 38411, 38223, 38104, 27463, 25518, 25418, 25127, 25128, 21414, 21131, 20897, 20898, 20894, 20896, 20899, 20895, 20893, 20504, 20137, 20138, 19908, 19880, 19807, 19243]
    csv_data = CSV.generate(write_headers: true, headers: headers) do |writer|
      @inquiries_number.each do |inq|
        inquiry = Inquiry.where(inquiry_number: inq).last
        writer << [inquiry.inquiry_number, inquiry.created_at, inquiry.quotation_date]
      end
    end
    temp_file = File.open(service, 'wb')
    temp_file.write(csv_data)
    temp_file.close
  end

  attr_accessor :inquiries_number, :missing_inquiry, :inquiry, :inquiry_present
end