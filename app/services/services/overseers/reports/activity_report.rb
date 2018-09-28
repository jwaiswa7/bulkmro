class Services::Overseers::Reports::ActivityReport < Services::Overseers::Reports::BaseReport
  def call
    call_base

    @data = OpenStruct.new(
        {
            geographies: [],
            entries: {}
        }
    )

    activities = Activity.all.where(:created_at => report.start_at..report.end_at).joins(:created_by)
    geographies = Overseer.joins(:activities).top(:geography)
    geographies.each do |geography_name, geography_count|
      activities = activities.where('overseers.geography = ?', geography_name)
      geography = OpenStruct.new({
                                     name: geography_name,
                                     count: geography_count,
                                     meeting: activities.meeting.count,
                                     not_meeting: activities.not_meeting.count,
                                 })

      overseers = []
      activities.top('activities.created_by_id').each do |overseer_id, overseer_count|
        overseers.push(OpenStruct.new({ id: overseer_id, name: Overseer.find(overseer_id).full_name, count: overseer_count }))
      end

      ActiveRecord::Base.default_timezone = :utc
      activities.group('activities.created_by_id').group_by_day('activities.created_at').count.each do |overseer_id_and_date, count|
        data.entries.merge!({ overseer_id_and_date[1] => { overseer_id_and_date[0] => count }})
      end
      ActiveRecord::Base.default_timezone = :local

      geography.overseers = overseers
      data.geographies.push(geography)
    end

    data
  end
end