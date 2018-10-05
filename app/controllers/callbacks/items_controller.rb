class Callbacks::ItemsController < Callbacks::BaseController
  def update
    sku = params[:sku]
    uom = params[:uom_name]
    weight = params[:weight]

    begin
      product = Product.find_by_sku!(sku)
      product.update_attributes(:measurement_unit => MeasurementUnit.where('LOWER(name) = ?', uom.downcase).first) if uom.present?
      product.update_attributes(:weight => weight) if product.respond_to?(:weight) && weight.present?

      render_successful
    rescue => e
      render_unsuccessful
    end
  end
end
