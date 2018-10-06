class Services::Overseers::Reports::PipelineReport < Services::Overseers::Reports::BaseReport
  def call
    call_base

    @data = OpenStruct.new(
        {
            statuses: [],
            entries: {}
        }
    )

    inquiries = Inquiry.all.where(:created_at => report.start_at..report.end_at)
    statuses = Inquiry.top(:status)

    statuses.each do |status_title, status_inquiry_count|
      status = OpenStruct.new({
                                     name: status_title,
                                     count: status_inquiry_count,
                                 })

      data.statuses.push(status)

    end

    data
  end
end