class Callbacks::ImageReadersController < ApplicationController
  protect_from_forgery with: :null_session

  def update
    service = Services::Customers::ImageReaders::ImageReaderUpdate.new(params)
    render json: service.call || {}, status: :ok
  end
end
