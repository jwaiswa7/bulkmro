class ErrorsController < ApplicationController
  include Gaffe::Errors

  layout false

  skip_before_action :verify_authenticity_token

  def show
    render status: @status_code
  end
end
