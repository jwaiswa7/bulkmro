class Customers::ImageReadersController < Customers::BaseController
  require 'httparty'
  protect_from_forgery with: :null_session

  def create
    authorize :ImageReader
    request = Services::Customers::ImageReaders::ImageReaderCreate.new.call
  end

  def update
    request = Services::Customers::ImageReaders::ImageReaderUpdate.new(params).call
  end

  # def get_data
  #   authorize :ImageReader
  #   debugger
  # end

  # def index
  #   response = HTTParty.get("https://api.playment.in/v1/project/fd3f4026-a21e-4191-9373-3e775c494d3e/feedline", body: {})
  #   response.parsed_response
  # end
end