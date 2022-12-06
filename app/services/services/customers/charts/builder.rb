class Services::Customers::Charts::Builder < Services::Shared::BaseService
  def initialize(daterange, company_id)
    @start_at = daterange ? daterange.split('~')[0].to_date : Date.new(2018, 4, 1).beginning_of_month
    @end_at = daterange ? daterange.split('~')[1].to_date : Date.today.end_of_month
    @company_id = company_id
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

  attr_accessor :start_at, :end_at, :company_id
end
