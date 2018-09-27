class Callbacks::ItemWeightsController < Callbacks::BaseController
  protect_from_forgery with: :null_session
  before_action :authenticate_callback

  def update
    resp_status = 0
    resp_msg = 'Invalid request'
    #request params {"sku":"I1110","weight":"2.5","uom_name":"NOS"}
    update = false
    if params[:sku].present?
      #check sku exist
      if Product.exists?(sku: params[:sku])
        product = Product.find_by_sku(params[:sku])
        # Update uomname and weight
        if params[:uom_name].present?
          unit = MeasurementUnit.where('lower(name) = ?', params[:uom_name].downcase).first
          if unit && product.measurement_unit_id != unit.id
            product.measurement_unit_id = unit.id
            update = true
          end
        end
        <<-DOC
        # to-do as not in product weight
        if params[:weight].present? && product.weight != params[:weight]
         product.weight = params[:weight]
         update = true
        end
        DOC

        if update
          begin
            product.save
            resp_status = 1
            resp_msg = 'Item updated successfully'
          rescue => e
            resp_status = 0
            resp_msg = 'Item updated failed. Error: ' + e.message
          end
        else
          resp_status = 0
          resp_msg = 'Item update skipped'
        end
      else
        resp_msg = 'Item code does not exists'
      end
    end
    response = format_response(resp_status, resp_msg)
    render json: response, status: :ok
  end
end