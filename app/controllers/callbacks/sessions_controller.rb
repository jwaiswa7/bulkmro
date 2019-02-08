# frozen_string_literal: true

class Callbacks::SessionsController < Callbacks::BaseController
  skip_before_action :authenticate_callback!
  EMAIL = "ashwin.goyal@bulkmro.com"
  PASSWORD = "abc123"

  def new
    @callback_request = CallbackRequest.where(method: self.to_callback_request(request.method.to_s), resource: controller_name.classify, request: params).first_or_create do |callback_request|
      callback_request.update(
        method: self.to_callback_request(request.method.to_s),
        resource: controller_name.classify,
        request: params,
        url: request.url,
        status: :pending
      )
    end

    if EMAIL == params[:email].downcase && PASSWORD == params[:password]
      sap_api_key = ActiveRecord::Base.generate_unique_secure_token
      Rails.cache.write(:sap_api_key, sap_api_key, expires_in: 25.minutes)

      response = { success: 1, status: :success, api_key: sap_api_key }

      @callback_request.update(
        response: response.to_json,
        status: :success,
        hits: @callback_request.hits.to_i + 1,
          ) if @callback_request.present?

      render json: response, status: :ok
    else
      response = { success: 0, status: :failed, message: "Invalid username or password." }
      @callback_request.update(
        response: response.to_json,
        status: :failed,
        hits: @callback_request.hits.to_i + 1,
          ) if @callback_request.present?

      render json: response, status: 401
    end
  end

  def to_callback_request(request_type)
    case request_type
    when "POST"
      :post
    when "GET"
      :get
    when "PATCH"
      :patch
    end
  end
end
