class Services::Shared::Charts::ChartConfig < Services::Shared::BaseService
  def initialize
    @start_at = Date.new(2018, 04, 01)
    @end_at = Time.now.end_of_month
  end

  def mixed_chart
    @chart = []
    @data = {
        labels: [],
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
        }
    }
  end

  attr_accessor :start_at, :end_at
end