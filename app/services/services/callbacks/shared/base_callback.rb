

class Services::Callbacks::Shared::BaseCallback < Services::Shared::BaseService
  def initialize(params, callback_request)
    @params = params
    @callback_request = callback_request
  end

  def return_response(message, status=1)
    response = { success: status, status: status, message: message }
    @callback_request.update(
      response: response.to_json,
      status: self.to_callback_status(status),
      hits: @callback_request.hits.to_i + 1,
    ) if @callback_request.present?
    response
  end

  def to_callback_status(status)
    case status.to_s
    when "1"
      :'success'
    when "0"
      :'failed'
    end
  end

  attr_accessor :params
end
