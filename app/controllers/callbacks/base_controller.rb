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
  def self.model_name
    self.name.split('::').last.to_s
  end
  def log_request(method,request)
    RemoteExchangeLog.create({
                                 method: method,
                                 resource: model_name,
                                 request_message: request,
                                 url: model_name,
                                 status: :pending
                             })
  end
  private
  def authenticate_callback
    puts(params)

    authenticate_or_request_with_http_token do |token, options|
      Rails.cache.fetch(:sap_callbacks_key)
    end
  end
end