class Services::Callbacks::Shared::BaseCallback < Services::Callbacks::Shared::BaseCallback

  def initialize(params)
    @params = params

    @response = {
        success: nil,
        status: nil,
        message: nil
    }
  end

  def set_response(message, status=1)
    response.merge({ success: status, status: status, message: message})
  end

  attr_accessor :params
end