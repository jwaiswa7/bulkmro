class Callbacks::BaseController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_callback!
  before_action :log_request

  def format_response(status, message, response = nil)
    Hash.new({
                 success: status,
                 status: status,
                 message: message,
                 response: response
             })
  end

  def log_request
    RemoteRequest.create({
                             method: :callback,
                             resource: self.class.name,
                             request: params,
                             url: request.url,
                             status: :pending
                         })
  end

  private

  def authenticate_callback!
    authenticate_or_request_with_http_token do |token, options|
      token == Rails.cache.fetch(:sap_api_key) ? true : false
    end
  end
end