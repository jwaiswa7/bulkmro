class Services::Shared::Charts::ChartConfig < Services::Shared::BaseService
  def initialize
    @start_at = Time.new(2018, 04, 01).beginning_of_month
    @end_at = Time.now.end_of_month
    @chart = {
        :data => {},
        :options => {}
    }
    @data = {}
    @options = {}
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

  attr_accessor :start_at, :end_at
end