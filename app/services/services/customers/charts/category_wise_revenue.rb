class Services::Customers::Charts::CategoryWiseRevenue < Services::Customers::Charts::Builder
  def initialize
    super
    # @start_at = start_at
    # @end_at = end_at
  end

  def call(company)
    build_chart do
      @data = {
          labels: [],
          datasets: [
              {
                  label: "Categorywise Revenue",
                  type: "doughnut",
                  borderColor: "#fd7e14",
                  backgroundColor: ["#3e95cd", "#8e5ea2","#3cba9f","#e8c3b9","#c45850", '#fd7e14'],
                  data: [],
              }
          ]
      }

      @options = {

      }

      sales_orders = SalesOrder.includes(:rows).remote_approved.where(:created_at => start_at..end_at).joins(:company).where(companies: {id: company.id}).joins(:products)
      sales_orders.map{|so| so.products.map{ |pc| pc.category }}.flatten.uniq

      (start_at..end_at).map {|a| a.strftime("%b-%y") }.uniq.each do |month|
        @data[:labels].push(month)
        @data[:datasets][0][:data].push(ordered_products.where('sales_orders.created_at' => month.to_date.beginning_of_month..month.to_date.end_of_month).map{|so| so.products}.flatten.uniq.count)
      end
    end
  end

  attr_accessor :start_at, :end_at
end