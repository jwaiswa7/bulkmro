class Customers::ReportsController < Customers::BaseController

  def quarterly_purchase_data
    authorize :report, :show?
    # date_start = Time.now.beginning_of_month
    # date_end = Time.now.end_of_month

    ActiveRecord::Base.default_timezone = :utc
    data = Inquiry.where(:status == "Order Won").limit(10).group_by_month(:created_at).count
    puts "DATA", data
    # @chart  = Services::Customers::Charts::DataGenerator.new(product_data, product_quantity, date_start, date_end).call

  end
end




filter options
controller
service with methods #for diff graphs
different helpers as well
view