class Customers::ImageReadersController < Customers::BaseController
  require 'httparty'
  protect_from_forgery with: :null_session
  before_action :set_headers, only: [:export_all, :export_by_date]

  def create
    authorize :ImageReader
    Services::Customers::ImageReaders::ImageReaderCreate.new.call

    redirect_to customers_image_readers_path
  end

  def index
    authorize :ImageReader
    @completed_records = ImageReader.where(status: 'completed').group('DATE(created_at)').count
  end

  def export_all
    service = Services::Overseers::Exporters::ImageReadersExporter.new(headers)
    self.response_body = service.call
    # Set the status to success
    response.status = 200
  end

  def export_by_date
    service = Services::Overseers::Exporters::ImageReadersForDateExporter.new(params, headers)
    self.response_body = service.call
    # Set the status to success
    response.status = 200
  end
end
