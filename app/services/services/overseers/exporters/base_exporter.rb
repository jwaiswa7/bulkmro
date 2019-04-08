class Services::Overseers::Exporters::BaseExporter < Services::Shared::BaseService
  def initialize(*args)
    @arguments = args
    @start_at = Date.new(2018, 10, 19)
    @end_at = Date.today.end_of_day
    @overseer = args[1]
    if args[0].present? && (args[0].include? '~')
      range = args[0].split('~')
      @start_at = range[0].strip.to_date
      @end_at = range[1].strip.to_date.end_of_day
    elsif args[2].present?
      @ids = args[2].pluck(:id).uniq
    end
    @rows = []
  end

  def filename
    "#{export_name}.csv"
  end

  def generate_csv(object)
    csv_data = CSV.generate(write_headers: true, headers: columns) do |csv|
      rows.each do |row|
        csv << row.values
      end
    end

    temp_file = File.open(Rails.root.join('tmp', filename), 'wb')
    begin
      temp_file.write(csv_data)
      temp_file.close
      object.report.attach(io: File.open(temp_file.path), filename: filename)
      object.save!
      if @ids.present?
        ExportMailer.export_filtered_records(object, @overseer).deliver_now
      end
    rescue => ex
      puts ex.message
    end
  end

  attr_accessor :start_at, :end_at, :columns, :model, :rows, :path, :export_name, :arguments
end
