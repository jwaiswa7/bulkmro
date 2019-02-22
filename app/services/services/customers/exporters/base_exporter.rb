class Services::Customers::Exporters::BaseExporter < Services::Shared::BaseService

  def initialize(headers, file_name)
    @start_at = Date.new(2018, 04, 01)
    @end_at = Date.today.end_of_day
    @rows = []

    # Tell Rack to stream the content
    headers.delete("Content-Length")

    # Don't cache anything from this generated endpoint
    headers["Cache-Control"] = "no-cache"

    # Tell the browser this is a CSV file
    headers["Content-Type"] = "text/csv"

    # Make the file download with a specific filename
    headers["Content-Disposition"] = "attachment; filename=\"#{file_name}.csv\""

    # Don't buffer when going through proxy servers
    headers["X-Accel-Buffering"] = "no"
  end

  attr_accessor :start_at, :end_at, :columns, :model, :rows, :company
end