class Api::V1::BaseController < ActionController::API
  include HTTParty
  include ActionController::MimeResponds
end
