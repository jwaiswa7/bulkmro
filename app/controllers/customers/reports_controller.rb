class Customers::ReportsController < Customers::BaseController

  def quarterly_purchase_data
    authorize :report, :show?
    date_start = Time.now.beginning_of_month
    date_end = Time.now.end_of_month
    product_data = []
    product_quantity = []

    CustomerOrderRow.all.each do |record|
      product_data.push(record.product_id)
      product_quantity.push(record.quantity)
    end

    # @chart  = Services::Customers::Charts::DataGenerator.new(product_data, product_quantity, date_start, date_end).call

    @data = CustomerOrderRow.group(:product).count
  end

end

