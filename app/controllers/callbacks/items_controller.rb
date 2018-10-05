class Callbacks::ItemsController < Callbacks::BaseController
  def update
    sku = params[:sku]
    uom = params[:uom_name]
    weight = params[:weight]

    begin
      product = Product.find_by_sku!(sku)
      product.update_attributes(:measurement_unit => MeasurementUnit.where('LOWER(name) = ?', uom.downcase).first) if uom.present?
      product.update_attributes(:weight => weight) if product.respond_to?(:weight) && weight.present?

      response_status = 1
      response_message = 'Successful'
      render json: format_response(response_status, response_message), status: :ok
    rescue => e
      response_status = 0
      response_message = 'Item updated failed. Error: ' + e.message
      render json: format_response(response_status, response_message), status: 500
    end
  end
end
