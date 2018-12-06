class Services::Overseers::Exporters::BaseExporter < Services::Shared::BaseService

  def initialize
    @start_at = Date.new(2018, 10, 19)
    @end_at = Date.today.end_of_day
    @rows = []
  end

  def filename
    "#{model.name.pluralize.downcase}.csv"
  end

  def generate_csv
    CSV.open(path, 'w',write_headers: true, headers: columns) do |csv|
      rows.each do |row|
        csv << row.values
      end
    end
    temp_file = Tempfile.new
    temp_file.puts(File.open(path))
    temp_file
  end

  attr_accessor :start_at, :end_at, :columns, :model, :rows, :path
end