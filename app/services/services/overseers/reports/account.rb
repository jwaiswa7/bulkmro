

class Services::Overseers::Reports::Account
  def initialize(account, params)
    @account = account
    @params = params
  end

  def call
    @data = OpenStruct.new(
      geographies: [],
      entries: {},
      columns: {},
      summaries: {}
    )

    start_at = Date.new(2018, 04, 01)
    end_at = Date.today.end_of_day

    ActiveRecord::Base.default_timezone = :utc

    companies = @account.companies
    sales_orders = @account.sales_orders.includes([rows: :sales_quote_row]).where(created_at: start_at.beginning_of_month..end_at.end_of_month).where("sales_orders.status = ? OR sales_orders.legacy_request_status = ?", SalesOrder.statuses[:'Approved'], SalesOrder.statuses[:'Approved'])
    months = sales_orders.group_by_month("sales_orders.created_at", default_value: nil).count
    @data.columns = months

    @data.summaries["total"] ||= {}
    companies.each do |company|
      @data.entries[company.name] ||= {}
      company_sales_orders = sales_orders.joins(:company).where("companies.id = ?", company.id)

      months.each do |month, value|
        @data.entries[company.name][month.to_s] ||= 0
        @data.summaries["total"][month.to_s] ||= 0
        @data.entries[company.name][month.to_s] = company_sales_orders.where(created_at: month.to_date.beginning_of_month..month.to_date.end_of_month).map{ |s| s.calculated_total }.compact.inject(0){ |sum, x| sum + x }.to_f.round(2)
        @data.summaries["total"][month.to_s] = @data.summaries["total"][month.to_s] + @data.entries[company.name][month.to_s]
      end
    end

    ActiveRecord::Base.default_timezone = :local

    @data
  end
end
