class Services::Callbacks::Shared::BaseCallback < Services::Shared::BaseService

  def initialize(params)
    @params = params
  end

  def return_response(message, status=1)
    { success: status, status: status, message: message}
  end

  attr_accessor :params
end