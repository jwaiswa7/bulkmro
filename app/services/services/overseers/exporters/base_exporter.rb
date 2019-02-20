class Services::Overseers::Exporters::BaseExporter < Services::Shared::BaseService
  def initialize(*args)
    @arguments = args
    @start_at = Date.new(2018, 10, 19)
    @end_at = Date.today.end_of_day
    if args[0].present? && (args[0].include? '~')
        range = args[0].split("~")
        @start_at = range[0].strip.to_date
        @end_at = range[1].strip.to_date.end_of_day
    end
    @rows = []

    # Tell Rack to stream the content
    headers.delete('Content-Length')

    # Don't cache anything from this generated endpoint
    headers['Cache-Control'] = 'no-cache'

    # Tell the browser this is a CSV file
    headers['Content-Type'] = 'text/csv'

    # Make the file download with a specific filename
    headers['Content-Disposition'] = "attachment; filename=\"#{file_name}.csv\""

    # Don't buffer when going through proxy servers
    headers['X-Accel-Buffering'] = 'no'
  end

  attr_accessor :start_at, :end_at, :columns, :model, :rows, :path, :export_name, :arguments
end
