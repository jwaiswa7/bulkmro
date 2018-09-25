class Callbacks::ItemWeightsController < Callbacks::BaseController
  protect_from_forgery with: :null_session
  before_action :authenticate_callback

  def update
    resp_status = 0
    resp_msg = 'Invalid request.'
    #request params {"sku":"I1110","weight":"2.5","uom_name":"NOS"}
    if params['sku'] != ''
      #check sku exist
      if 1 #sku.present
        # Update uomname and weight
        resp_status = 1
        resp_msg = 'Item updated successfully'
      else
        resp_msg = 'Item code does not exists'
      end
    end
    response = format_response(resp_status, resp_msg)
    render json: response, status: :ok
  end
end