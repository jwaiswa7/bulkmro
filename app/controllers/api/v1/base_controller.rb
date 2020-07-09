class Api::V1::BaseController < ActionController::API
  # skip_before_filter :authenticate_customers_contact!
  # before_action :check_basic_auth
  # skip_before_action :verify_authenticity_token
  # before_action :configure_permitted_parameters, if: :devise_controller?
  include HTTParty
  include ActionController::MimeResponds
end