class Services::Customers::Charts::DataGenerator < Services::Shared::BaseService
  def initialize()
    super
  end

  def get_multi_axis_mixed_chart(revenue_data, products_count, months)
    @chart = []
    @data = {
        labels: months,
        datasets: [{
            label: "Products",
            type: "line",
            borderColor: "#ff0000",
            backgroundColor: "#ff0000",
            data: [],
            yAxisID: 'products_count',
            fill: false
          },
          {
            label: "Orders",
            type: "bar",
            borderColor: "#8e5ea2",
            backgroundColor: '#50BB70',
            data: [],
            yAxisID: 'revenue',
            fill: false,
        }]
    }

    @options = {
        scales: {
            yAxes: [{
                        id: 'products_count',
                        type: 'linear',
                        position: 'right',
                    }, {
                        id: 'revenue',
                        type: 'linear',
                        position: 'left',
                        ticks:{
                           display:true,
                           userCallback: ''
                        },
                        scaleLabel: {
                            display: true,
                            labelString: 'Revenue'
                        }
                    }]
        },
        # title: {
        #     display: true,
        #     text: 'Order and Products Report'
        # },
    }

    months.each_with_index do |m, index|
      @data[:datasets][0][:data].push(products_count[index])
      @data[:datasets][1][:data].push(revenue_data[index])
    end
    @chart.push(@data, @options)
  end
end