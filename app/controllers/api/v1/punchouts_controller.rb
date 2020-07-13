class Api::V1::PunchoutsController < Api::V1::BaseController
  before_action :log_api_request
  
  def auth
    service = Services::Api::Cxml.new(request, @api_request)
    response_data = service.parser

    respond_to do |format|
      format.xml { render :xml => response_data }
    end
  end

  private

  def log_api_request
    @api_request = ApiRequest.create(
      endpoint: request.url,
      created_at: Time.now.iso8601
    )
  end
  
end
  