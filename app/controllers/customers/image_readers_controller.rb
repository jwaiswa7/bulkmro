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
    @completed_records = ImageReader.where(status: "completed").group_by{ |reader| reader.created_at.to_date }.map{|date,values| { date: date, count: values.count }}
  end

  def export_all
    authorize :ImageReader

    service = Services::Overseers::Exporters::ImageReadersExporter.new
    service.call

    redirect_to url_for(Export.image_readers.last.report)
  end

  def export_by_date
    authorize :ImageReader
    service = Services::Overseers::Exporters::ImageReadersForDateExporter.new(params)
    service.call

    redirect_to url_for(Export.image_readers_for_date.last.report)
  end


end