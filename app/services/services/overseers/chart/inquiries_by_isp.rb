class Services::Overseers::Chart::InquiriesByIsp

  def initialize(inquiries:)
    @inquiries = inquiries
    @inside_sales_owner_hash = Hash.new
    @status_count_hash = Hash.new
    statuses = @inquiries.pluck(:status).uniq
    @statuses =  Inquiry.statuses.select {|k,v| statuses.include?(k) }
  end
  

  def call 
    @inside_sales_owner_hash = build_inside_sales_owner_hash
    build_status_count_hash
    {
      data: data ,
      options: options
    }
  end

  private 
  attr_accessor :inquiries , :statuses, :status_hash, :inside_sales_owner_hash, :status_count_hash

  def build_inside_sales_owner_hash
    inside_sales_owner_hash = {}
    overseers = Overseer.where(id: (inquiries.group_by(&:inside_sales_owner_id).keys))
    overseers.each do |overseer|
      inside_sales_owner_hash[overseer.name] = overseer.id
    end
    inside_sales_owner_hash
  end

  def build_status_count_hash
    @inside_sales_owner_hash.each do |name, id|
      status_count_hash[name] = statuses.values.map{|s| inquiries.where(inside_sales_owner_id: id, status: s).count}
    end
  end

  def data_sets 
    data_array = []
    statuses.keys.each_with_index do |status, i|
      hash = {
        axis: 'y',
        label: status,
        data: status_count_hash.values.map{|v| v[i]},
        fill: false,
        backgroundColor: status_count_hash.values.map{ |v| colors[i]}
      }
      data_array.push hash
    end
    data_array
  end

  def colors
    [
      'rgba(137,219,253,255)', 'rgba(176,122,106,255)', 'rgba(247,218,209,255)', 'rgba(32,138,179,255)',
      'rgb(194,186,188)', 'rgba(112,126,126,255)', 'rgba(24,93,121,255)', 'rgba(224,68,167,255)', 'rgba(82,78,71,255)',
      'rgba(86,7,13,255)', 'rgba(54,126,111,255)', 'rgb(25, 83, 95)', 'rgb(141, 153, 174)', 'rgb(78, 2, 80)',
      'rgb(150, 230, 179)', 'rgb(218, 62, 82)', 'rgb(216, 17, 89)'
    ]
  end


  

  def data 
    {
      labels: @inside_sales_owner_hash.keys,
      datasets: data_sets
    };
  end

  def options 
    {
      height: 5000,
      scales: {
        xAxes: [{
            stacked: true
        }],
        yAxes: [{
            stacked: true
        }]
      }, 
      legend: {display: true}
    }
  end
end
