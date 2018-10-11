class Services::Overseers::Reports::ActivityReport < Services::Overseers::Reports::BaseReport
  def call
    call_base

    @data = OpenStruct.new(
        {
            geographies: [],
            entries: {}
        }
    )
    all_activities = Activity.all.joins(:created_by)
    activities = all_activities.where(:created_at => report.start_at..report.end_at).joins(:created_by)
    geographies = Overseer.joins(:activities).top(:geography)
    geographies.each do |geography_name, geography_count|

      geo_activities = activities.where('overseers.geography = ?', geography_name)
      overseers = []
      if !geo_activities.present?
        ga = all_activities.where('overseers.geography = ?', geography_name)
        ga.top('activities.created_by_id').each do |overseer_id, overseer_count|
          overseers.push(OpenStruct.new({id: overseer_id, name: Overseer.find(overseer_id).full_name, count: 0}))
        end
      else
        geo_activities.top('activities.created_by_id').each do |overseer_id, overseer_count|
          overseers.push(OpenStruct.new({id: overseer_id, name: Overseer.find(overseer_id).full_name, count: overseer_count}))
        end
      end
      #next if (!geo_activities.present?)

      geography = OpenStruct.new({
                                     name: geography_name,
                                     count: geography_count,
                                     meeting: geo_activities.meeting.count,
                                     not_meeting: geo_activities.not_meeting.count,
                                 })


      sql_query = "SELECT COUNT(*) AS count_all, activities.created_by_id AS activities_created_by_id, (DATE_TRUNC('day', (activities.created_at::timestamptz))) AS date_trunc_day_activities_created_at_timestamptz_at_time_zone_e FROM activities JOIN overseers ON overseers.id = activities.created_by_id WHERE activities.created_at BETWEEN ? AND ? AND (overseers.geography = ?) AND (activities.created_at IS NOT NULL) GROUP BY activities.created_by_id, (DATE_TRUNC('day', (activities.created_at::timestamptz)))"

      sql_data = ActiveRecord::Base.connection.execute(sql_query, report.start_at, report.end_at, geography_name)
      sql_data.each do |a|
        overseer_id_and_date = [a['activities_created_by_id'], a['date_trunc_day_activities_created_at_timestamptz_at_time_zone_e'].to_date]
        if data[:entries][overseer_id_and_date[1]].present?
          data[:entries][overseer_id_and_date[1]].merge!({overseer_id_and_date[0] => a['count_all']})
        else
          data[:entries][overseer_id_and_date[1]] = {overseer_id_and_date[0] => a['count_all']}
        end
      end

      geography.overseers = overseers
      data.geographies.push(geography)
    end

    data
  end
end