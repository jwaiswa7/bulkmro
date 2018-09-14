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

  private

  def authenticate_callback
    authenticate_or_request_with_http_token do |token, options|
      # token == Rails.cache.fetch(:sap_callbacks_key) ? true: false
      1
    end
  end
end