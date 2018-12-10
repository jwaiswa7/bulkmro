class Services::Customers::Charts::DataGenerator < Services::Shared::BaseService

  def initialize()
    super
  end

  def get_multi_axis_mixed_chart(revenue_data, quarter_months)
    @chart = []
    @data = {
        labels: quarter_months,
        datasets: [{
                       label: "Orders",
                       type: "bar",
                       borderColor: "#8e5ea2",
                       backgroundColor: '#50BB70',
                       data: [],
                       yAxisID: 'revenue',
                       fill: false,
                   },
                   {
                       label: "Products",
                       type: "line",
                       borderColor: "#47A7D4",
                       backgroundColor: "#47A7D4",
                       data: [9, 7, 3],
                       yAxisID: 'products_count',
                       fill: false
                   }]
    }
    @options = {
        scales: {
            yAxes: [{
                        id: 'revenue',
                        type: 'linear',
                        position: 'left',
                    }, {
                        id: 'products_count',
                        type: 'linear',
                        position: 'right',

                    }]
        }
    }
    quarter_months.each_with_index do |m, index|
      @data[:datasets][0][:data].push(revenue_data[index])
    end
    @chart.push(@data, @options)
  end

end