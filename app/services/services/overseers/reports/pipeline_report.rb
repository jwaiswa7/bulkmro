class Services::Overseers::Reports::PipelineReport < Services::Overseers::Reports::BaseReport
  def call
    call_base

    @data = OpenStruct.new(
      statuses: [],
      entries: {},
      summary_entries: {}
    )

    inquiries = Inquiry.includes(sales_quotes: [{ sales_quote_rows: :supplier }]).where(created_at: report.start_at.beginning_of_month..report.end_at.end_of_month)

    status_groups = Inquiry.top(:status)
    status_groups.each do |status_name, status_count|
      status_inquiries = inquiries.send(status_name)
      data.statuses.push(OpenStruct.new(name: status_name, count: status_count))

      ActiveRecord::Base.default_timezone = :utc
      inquiry_groups = status_inquiries.group_by_month(:created_at, default_value: nil).count
      inquiry_groups.each do |month, inquiries_count|
        data[:entries][month] ||= {}
        data[:entries][month][status_name] ||= {}
        data[:entries][month][status_name][:count] ||= inquiries_count
        data[:entries][month][status_name][:value] ||= status_inquiries.where(created_at: month.beginning_of_month..month.end_of_month).sum(:calculated_total)

        data[:entries][month][:count] ||= inquiries.where(created_at: month.beginning_of_month..month.end_of_month).size
        data[:entries][month][:value] ||= inquiries.where(created_at: month.beginning_of_month..month.end_of_month).sum(:calculated_total)
      end if inquiry_groups.present?

      inquiries.group_by_month(:created_at).count.each do |month, inquiries_count|
        data[:entries][month] ||= {}
        data[:entries][month][status_name] ||= {}
        data[:entries][month][status_name][:count] ||= 0
        data[:entries][month][status_name][:value] ||= 0
      end

      data[:summary_entries][:total_count] ||= {}
      data[:summary_entries][:total_count][status_name] ||= {}
      data[:summary_entries][:total_count][status_name][:count] ||= status_inquiries.size
      data[:summary_entries][:total_count][status_name][:value] ||= status_inquiries.sum(:calculated_total)
      data[:summary_entries][:total_count][:count] ||= inquiries.size
      data[:summary_entries][:total_count][:value] ||= inquiries.sum(:calculated_total)
    end

    inquiries.group_by_month(:created_at).count.each do |month, inquiries_count|
      if data[:entries][month][:count] && data[:entries][month][:value]
        data[:entries][month][:won_count] ||= ((inquiries.won.between_month_for(month).size.to_f / data[:entries][month][:count]) * 100).round(2)
        data[:entries][month][:won_value] ||= ((inquiries.won.between_month_for(month).sum(:calculated_total) / data[:entries][month][:value]) * 100).round(2)
      end
    end

    if data[:summary_entries][:total_count][:count] && data[:summary_entries][:total_count][:value]
      data[:summary_entries][:total_count][:won_count] ||= ((inquiries.won.size.to_f / data[:summary_entries][:total_count][:count].to_f) * 100).round(2)
      data[:summary_entries][:total_count][:won_value] ||= ((inquiries.won.sum(:calculated_total) / data[:summary_entries][:total_count][:value]) * 100).round(2)
    end

    ActiveRecord::Base.default_timezone = :local
    data
  end
end
