class Callbacks::SessionsController < Callbacks::BaseController
  skip_before_action :authenticate_callback!
  EMAIL = 'ashwin.goyal@bulkmro.com'
  PASSWORD = 'abc123'

  def new
    if EMAIL == params[:email].downcase && PASSWORD == params[:password]
      sap_api_key = ActiveRecord::Base.generate_unique_secure_token
      Rails.cache.write(:sap_api_key, sap_api_key, expires_in: 25.minutes)
      render json: {status: :success, api_key: sap_api_key}
    else
      render json: {status: :fail}, status: 401
    end
  end
end