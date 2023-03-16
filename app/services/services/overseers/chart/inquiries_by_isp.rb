class Services::Overseers::Chart::InquiriesByIsp

  def initialize 
    # @inquiries = Inquiry.select(:inside_sales_owner_id,:status).includes(:inside_sales_owner)
    # @statuses = Inquiry.statuses
    # @status_hash = Hash.new
    @inquiries = Inquiry.first(50)
  end
  

  def call 
    {
      data: data ,
      options: options
    }
  end

  private 
  attr_accessor :inquiries , :statuses, :status_hash

  def inside_sales_owners 
    inquiries.map{|inquiry| inquiry.inside_sales_owner&.name}.uniq
  end

  def inside_sales_owner_ids 
    inquiries.map{|inquiry| inquiry.inside_sales_owner_id }.uniq
  end

  # def status_series
  #   status_names = statuses.keys 

  #   inside_sales_owner_ids.each_with_index do |user_id, id_index|
  #     user_name = inside_sales_owners[id_index]
  #     user_status_count = inquiries.where(inside_sales_owner_id: user_id).map{|x| x.status}.group_by{|e| e}.map{|k, v| [k, v.length]}.to_h
  #     status_array = status_names.map{|status| 0 }
  #     user_status_count.each do |k,v|
  #       index = status_names.index(k)
  #       next if index.nil?
  #       status_array[index] = v
  #     end
  #     status_hash[user_name] = status_array
  #   end
  #   status_hash
  # end

  def labels 
    inquiries.map{ |inquiry| inquiry.inside_sales_owner.name }.uniq
  end

  def data_set 
    labels.map{|label| rand(10..100)}
  end

  def first_colors 
    labels.map {|label| 'rgba(137,219,253,255)'}
  end

  def second_colors 
    labels.map {|label| 'rgba(176,122,106,255)'}
  end

  def data 
    {
      labels: labels,
      datasets: [{
        axis: 'y',
        label: 'My First Dataset',
        data: data_set,
        fill: false,
        backgroundColor: first_colors,
      },
      {
        axis: 'y',
        label: 'My second Dataset',
        data:  data_set,
        fill: false,
        backgroundColor: second_colors,
      }]
    };
  end

  def options 
    {
      height: 700,
      scales: {
        xAxes: [{
            stacked: true
        }],
        yAxes: [{
            stacked: true
        }]
    }
    }
  end
end
      