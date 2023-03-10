class Services::Overseers::Chart::InquiriesByIsp
  

  def call 
    {
      data: data, 
      options: options
    }
  end

  private 
  def data 
    {
      labels: ["Amit Goyal", "Ashwin Goyal", "Creative Bulkmro", "Jeetendra Sharma", "Sarika Tanawade", "Swati Bhosale"],
      datasets: [{
        axis: 'y',
        label: 'My First Dataset',
        data: [65, 59, 80, 81, 56, 55, 40],
        fill: false,
        backgroundColor: [
          'rgba(137,219,253,255)',
          'rgba(137,219,253,255)',
          'rgba(137,219,253,255)',
          'rgba(137,219,253,255)',
          'rgba(137,219,253,255)',
          'rgba(137,219,253,255)',
          'rgba(137,219,253,255)'

        ],
        borderWidth: 1
      },
      {
        axis: 'y',
        label: 'My second Dataset',
        data: [83, 83, 72, 85, 43, 60, 86],
        fill: false,
        backgroundColor: [
          'rgba(176,122,106,255)',
          'rgba(176,122,106,255)',
          'rgba(176,122,106,255)',
          'rgba(176,122,106,255)',
          'rgba(176,122,106,255)',
          'rgba(176,122,106,255)',
          'rgba(176,122,106,255)'

        ],
        borderWidth: 1
      }]
    };
  end

  def options 
    {
      indexAxis: 'y',
      scales: {
        x: {
          stacked: true,
        },
        y: {
          stacked: true
        }
      }
    }
  end
end
      