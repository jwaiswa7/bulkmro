class Services::Overseers::Reports::BaseReport < Services::Shared::BaseService
  def initialize(report, params, current_overseer)
    @report = report
    @params = params
    @current_overseer = current_overseer
  end

  def call_base
    apply_date_range
  end

  def apply_date_range
    case report.date_range.to_sym
    when :today
      report.start_at = Time.now.beginning_of_day
      report.end_at = Time.now.end_of_day
    when :this_month
      report.start_at = Time.now.beginning_of_month
      report.end_at = Time.now.end_of_month
    when :last_week
      report.start_at = 1.week.ago.beginning_of_week
      report.end_at = 1.week.ago.end_of_week
    when :last_month
      report.start_at = 1.month.ago.beginning_of_month
      report.end_at = 1.month.ago.end_of_month
    when :custom
      report.start_at = report.start_at
      report.end_at = report.end_at
    else
      report.start_at = Time.now.beginning_of_month
      report.end_at = Time.now.end_of_month
    end
  end

  attr_reader :report, :data, :params
end
