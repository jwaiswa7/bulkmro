class Services::Shared::Charts::Builder < Services::Shared::BaseService
  def initialize
    @start_at = Date.new(2018, 04, 01).beginning_of_month
    @end_at = Date.today.end_of_month
    @data = {}
    @options = {}
    @chart = { data: @data, options: @options }
  end

  def build_chart
    ActiveRecord::Base.default_timezone = :utc
    yield if block_given?
    ActiveRecord::Base.default_timezone = :local

    @chart = {
        data: @data,
        options: @options
    }
  end

  attr_accessor :start_at, :end_at
end
