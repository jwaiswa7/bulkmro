class Callbacks::BaseController < ApplicationController
  protect_from_forgery with: :null_session
  # before_action :authenticate_callback!


  private
  def authenticate_callback
    authenticate_or_request_with_http_token do |token, options|
      token == Rails.cache.fetch(:sap_callbacks_key) ? true: false
    end
  end
end