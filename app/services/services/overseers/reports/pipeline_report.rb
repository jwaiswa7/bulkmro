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
    statuses.each do |status_title, status_inquiry_count|
      status_inquiries = inquiries
      status = OpenStruct.new({
                                     name: status_title,
                                     count: status_inquiry_count,
                                 })
      status_inquiries.group_by { |m| [m.created_at.beginning_of_month,m.status] }.each do |inquiry_month_and_status, status_month_inquiries|
        if data[:entries][inquiry_month_and_status[0].strftime("%b, %Y")].present?
          data[:entries][inquiry_month_and_status[0].strftime("%b, %Y")].merge!({ inquiry_month_and_status[1] => [ status_month_inquiries.count, status_month_inquiries.map{|i| i.sales_quotes.last.present? ? i.sales_quotes.last.sales_quote_rows.sum(&:total_selling_price).to_i : 0}.inject(0){|sum,x| sum + x }] })
        else
          data[:entries][inquiry_month_and_status[0].strftime("%b, %Y")] = { inquiry_month_and_status[1] => [ status_month_inquiries.count, status_month_inquiries.map{|i| i.sales_quotes.last.present? ? i.sales_quotes.last.sales_quote_rows.sum(&:total_selling_price).to_i : 0}.inject(0){|sum,x| sum + x }] }
        end
      end
      data.statuses.push(status)
    end
    data.entries.each do |month, value|
      data.entries[month]["Total"] = [value.values.sum { |number, value| number }, value.values.sum { |number, value| value }]
      data.entries[month]["Percentage"] = [((value["Order Won"][0].to_f / data.entries[month]["Total"][0].to_f)*100).round(2), ((value["Order Won"][1].to_f / data.entries[month]["Total"][1].to_f)*100).round(2)]
    end
    data
  end
end