class Services::Overseers::Reports::PipelineReport < Services::Overseers::Reports::BaseReport
  def call
    call_base

    @data = OpenStruct.new(
        {
            statuses: [],
            entries: {}
        }
    )

    inquiries = Inquiry.includes({ sales_quotes: [ { sales_quote_rows: :supplier }] }).all.where(:created_at => report.start_at.beginning_of_month..report.end_at.end_of_month)
    statuses = Inquiry.top(:status)
    statuses["Grand Total"] = inquiries.count
    statuses.each do |status_title, status_inquiry_count|
      if status_title != "Grand Total"
        status_inquiries = inquiries.where(status: status_title)
      else
        status_inquiries = inquiries
      end
      status = OpenStruct.new({
                                     name: status_title,
                                     count: status_inquiry_count,
                                 })
      if status_title != "Grand Total"
        status_inquiries.group_by { |m| [m.created_at.beginning_of_month,m.status] }.each do |inquiry_month_and_status, status_month_inquiries|
          if data[:entries][inquiry_month_and_status[0].strftime("%b, %Y")].present?
            data[:entries][inquiry_month_and_status[0].strftime("%b, %Y")].merge!({ inquiry_month_and_status[1] => [ status_month_inquiries.count, status_month_inquiries.map{|i| i.sales_quotes.last.present? ? i.sales_quotes.last.sales_quote_rows.sum(&:total_selling_price).to_i : 0}.inject(0){|sum,x| sum + x }] })
          else
            data[:entries][inquiry_month_and_status[0].strftime("%b, %Y")] = { inquiry_month_and_status[1] => [ status_month_inquiries.count, status_month_inquiries.map{|i| i.sales_quotes.last.present? ? i.sales_quotes.last.sales_quote_rows.sum(&:total_selling_price).to_i : 0}.inject(0){|sum,x| sum + x }] }
          end
        end
      else
        data[:entries].each do |entries_month,month_inquiries|
          data[:entries][entries_month].merge!( status_title => [ data[:entries][entries_month].values.map{|a| a[0]}.inject(0){|sum,x| sum + x }, data[:entries][entries_month].values.map{|a| a[1]}.inject(0){|sum,x| sum + x } ])
        end
      end
      data.statuses.push(status)
    end
    data
  end
end