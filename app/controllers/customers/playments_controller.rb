class Customers::PlaymentsController < Customers::BaseController
  require 'httparty'
  protect_from_forgery with: :null_session

  def create
    authorize :Playment
    request = Services::Customers::Playments::PlaymentCreate.new.call
  end

  # def get_data
  #   authorize :Playment
  #   debugger
  # end

  # def index
  #   response = HTTParty.get("https://api.playment.in/v1/project/fd3f4026-a21e-4191-9373-3e775c494d3e/feedline", body: {})
  #   response.parsed_response
  # end
end