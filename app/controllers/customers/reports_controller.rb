class Customers::ReportsController < Customers::BaseController

  def quarterly_purchase_data
    authorize :report, :show?

    ActiveRecord::Base.default_timezone = :utc
    inquiries = Inquiry.where(:status == "Order Won").where(:created_at => Time.now.beginning_of_quarter..Time.now.end_of_quarter)

    revenue_data = []
    inquiries.group_by_month(:created_at).sum("calculated_total").each do |month, revenue|
      revenue_data.push(revenue)
    end
    # inquiries.each_with_index do |inquiry, index|
    #   SalesOrder.where(:inquiry_id == inquiry[index].id).last.rows.count
    # end

    quarters = [[1,2,3], [4,5,6], [7,8,9], [10,11,12]]
    quarter_months = quarters[(Time.now.month - 1) / 3]

    service  = Services::Customers::Charts::DataGenerator.new()
    @chart = service.get_multi_axis_mixed_chart(revenue_data, quarter_months)
  end
end

