class Callbacks::SessionsController < Callbacks::BaseController
  EMAIL = 'ashwin.goyal@bulkmro.com'
  PASSWORD = 'abc123'

  def new
    if EMAIL == params[:email].downcase && PASSWORD == params[:password]
      sap_callbacks_key = ActiveRecord::Base.generate_unique_secure_token
      Rails.cache.write(:sap_callbacks_key, sap_callbacks_key, expires_in: 25.minutes)
      render json: { status: :success, api_key: sap_callbacks_key }
    else
      render json: { status: :fail }, status: 401
    end
  end
end