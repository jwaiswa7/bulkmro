class Services::Overseers::Chart::InquiriesByLocation
  def initialize(inquiries:)
    @locations = inquiries.select(:bill_from_id).includes(:bill_from).map { |i| i.bill_from&.address&.city_name}
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
        labels: addresses,
        datasets: [{
          label: 'My First Dataset',
          data: values,
          backgroundColor: colors,
          borderWidth: border_width,
          hoverOffset: 4
        }]
      }
    end

    def options 
      {height: '200px', legend: { display: true, position: 'right' }}
    end

    def addresses
      locations.uniq
    end

    def values
      addresses.map { |address| locations.count(address)}
    end

    def border_width
      addresses.map { |address| 0}
    end

    def colors
      [
        'rgb(78, 2, 80)', 'rgba(176,122,106,255)', 'rgba(247,218,209,255)', 'rgba(32,138,179,255)',
        'rgb(194,186,188)', 'rgba(112,126,126,255)', 'rgba(24,93,121,255)', 'rgba(224,68,167,255)', 'rgba(82,78,71,255)',
        'rgba(86,7,13,255)', 'rgba(54,126,111,255)', 'rgb(25, 83, 95)', 'rgb(141, 153, 174)',
        'rgb(150, 230, 179)', 'rgb(218, 62, 82)', 'rgb(216, 17, 89)'
      ]
    end

    attr_accessor :locations
end
