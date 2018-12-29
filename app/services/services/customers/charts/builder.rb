class Services::Customers::Charts::Builder < Services::Shared::BaseService

  def initialize(report)
    @report = report['daterange'] || ''
    @start_at = Date.new(2018,4,1).beginning_of_month
    @end_at = Date.today.end_of_month
    @data = {}
    @options = {}
    @chart = {:data => @data, :options => @options}
  end

  def build_chart
    ActiveRecord::Base.default_timezone = :utc
    yield if block_given?
    ActiveRecord::Base.default_timezone = :local

    @chart = {
        :data => @data,
        :options => @options
    }
  end

  def call_base
    # apply_date_range
  end

  def apply_date_range
    case report.daterange.to_sym
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

  attr_reader :report, :start_at, :end_at

end