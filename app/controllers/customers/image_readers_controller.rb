

class Customers::ImageReadersController < Customers::BaseController
  require "httparty"
  protect_from_forgery with: :null_session
  before_action :set_headers, only: [:export_all, :export_by_date]

  def create
    authorize :ImageReader
    Services::Customers::ImageReaders::ImageReaderCreate.new.call

    redirect_to customers_image_readers_path
  end

  def index
    authorize :ImageReader
    @completed_records = ImageReader.where(status: "completed").group("DATE(created_at)").count
  end

  def export_all
    # Set an Enumerator as the body
    self.response_body = total_exporter
  end

  def export_by_date
    # Set an Enumerator as the body
    self.response_body = exporter_for_date
  end

  private

    def total_exporter
      service = Services::Overseers::Exporters::ImageReadersExporter.new
      service.call
    end

    def exporter_for_date
      service = Services::Overseers::Exporters::ImageReadersForDateExporter.new(params)
      service.call
    end

    def set_headers
      authorize :ImageReader
      # Tell Rack to stream the content
      headers.delete("Content-Length")

      # Don't cache anything from this generated endpoint
      headers["Cache-Control"] = "no-cache"

      # Tell the browser this is a CSV file
      headers["Content-Type"] = "text/csv"

      # Make the file download with a specific filename
      headers["Content-Disposition"] = "attachment; filename=\"image_reader.csv\""

      # Don't buffer when going through proxy servers
      headers["X-Accel-Buffering"] = "no"

      # Set the status to success
      response.status = 200
    end
end
