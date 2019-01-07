class Customers::ImageReadersController < Customers::BaseController
  require 'httparty'
  protect_from_forgery with: :null_session

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
    authorize :ImageReader
    # service = Services::Overseers::Exporters::ImageReadersExporter.new
    # service.call

    # redirect_to url_for(Export.image_readers.last.report)
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

    # Set an Enumerator as the body
    self.response_body = body

    # Set the status to success
    response.status = 200
  end

  def export_by_date
    authorize :ImageReader
    service = Services::Overseers::Exporters::ImageReadersForDateExporter.new(params)
    service.call

    redirect_to url_for(Export.image_readers_for_date.last.report)
  end

  private

  def body
    Enumerator.new do |yielder|
      ImageReader.all.each do |record|
        # sleep 0.05
        yielder << CSV.generate_line([record.image_url, record.meter_number])
      end
    end
  end

end