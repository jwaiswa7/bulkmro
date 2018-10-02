class Callbacks::BaseController < ApplicationController
  protect_from_forgery with: :null_session
  # before_action :authenticate_callback!

  def format_response(status, msg, resp = nil)
    response = Hash.new
    response['success'] = status
    response['status'] = status
    response['message'] = msg
    response['response'] = resp
    response
  end


  def log_request(method,resource, request)
    RemoteExchangeLog.create({
                                 method: method,
                                 resource: resource,
                                 request_message: request,
                                 url: resource,
                                 status: :pending
                             })
  end
  private

  def authenticate_callback
    authenticate_or_request_with_http_token do |token, options|
      token == Rails.cache.fetch(:sap_callbacks_key) ? true: false
    end
  end
end