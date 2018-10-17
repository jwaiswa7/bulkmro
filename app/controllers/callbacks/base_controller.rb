class Callbacks::BaseController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_callback!
  before_action :log_request

  def create
    service_class = ['Services', 'Callbacks', controller_name.classify.pluralize, 'Create'].join('::').constantize
    service = service_class.new(params)
    render json: service.call || {}, status: :ok
  end

  def update
    service_class = ['Services', 'Callbacks', controller_name.classify.pluralize, 'Update'].join('::').constantize
    service = service_class.new(params)
    render json: service.call || {}, status: :ok
  end

  def render_successful(status = 1, message = 'Request successfully handled', response = nil)
    render json: {success: status, status: status, message: message, response: response}, status: :ok
  end

  def render_unsuccessful(status = 0, message = 'Request unsuccessful', response = nil)
    render json: {success: status, status: status, message: message, response: response}, status: 500
  end

  def log_request
    CallbackRequest.create({
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