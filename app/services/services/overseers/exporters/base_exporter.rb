class Services::Overseers::Exporters::BaseExporter < Services::Shared::BaseService

  def initialize
    @start_at = Date.new(2018, 10, 19)
    @end_at = Date.today.end_of_day
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
    rescue => ex
      puts ex.message
    end
  end

  attr_accessor :start_at, :end_at, :columns, :model, :rows, :path, :export_name
end