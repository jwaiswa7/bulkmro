class Api::V1::PunchoutsController < Api::V1::BaseController
  before_action :log_api_request, :debug_log_request

  def auth
    service = Services::Api::Cxml.new(request, @api_request)
    response_data = service.parser

    if response_data
      respond_to do |format|
        format.html { render xml: response_data.to_xml }
      end
    end
  end

  private

  def log_api_request
    @api_request = ApiRequest.create(
      endpoint: request.url,
      created_at: Time.now.iso8601
    )
  end

  def debug_log_request
    headers = request.headers.env.select do |k, _|
      k.downcase.start_with?('http') ||
      k.in?(ActionDispatch::Http::Headers::CGI_VARIABLES)
    end
    MyLog.debug headers
    MyLog.debug request.format
  end
end
  