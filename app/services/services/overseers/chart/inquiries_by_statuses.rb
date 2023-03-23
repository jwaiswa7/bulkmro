class Services::Overseers::Chart::InquiriesByStatuses
  def initialize
    start_of_financial_year = Date.today.beginning_of_financial_year
    end_of_financial_year = Date.today.end_of_financial_year
    @inquiries = Inquiry.where(created_at: start_of_financial_year .. end_of_financial_year).select(:status).group(:status).count
  end

  def call
    {
      data: data,
      options: options
    }
  end

  private

    def data
      {
        labels: statuses,
        datasets: [{
          data: values,
          backgroundColor: colors,
          borderWidth: border_width,
          hoverOffset: 4
        }]
      }
    end

    def options
      {
        height: '200px',
        legend: { display: false, position: 'right' },
      }
    end

    def statuses
      inquiries.keys
    end

    def values
      inquiries.values
    end

    def border_width
      statuses.map { |status| 0}
    end

    def colors
      [
        'rgba(137,219,253,255)', 'rgba(176,122,106,255)', 'rgba(247,218,209,255)', 'rgba(32,138,179,255)',
        'rgb(194,186,188)', 'rgba(112,126,126,255)', 'rgba(24,93,121,255)', 'rgba(224,68,167,255)', 'rgba(82,78,71,255)',
        'rgba(86,7,13,255)', 'rgba(54,126,111,255)', 'rgb(25, 83, 95)', 'rgb(141, 153, 174)', 'rgb(78, 2, 80)',
        'rgb(150, 230, 179)', 'rgb(218, 62, 82)', 'rgb(216, 17, 89)'
      ]
    end

    attr_accessor :inquiries
end
