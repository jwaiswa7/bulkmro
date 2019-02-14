# frozen_string_literal: true

class Services::Callbacks::Products::Update < Services::Callbacks::Shared::BaseCallback
  def call
    begin
      sku = params[:sku]
      uom = params[:uom_name]
      weight = params[:weight]

      product = Product.find_by_sku!(sku)

      if product.present?
        product.update_attributes!(measurement_unit: MeasurementUnit.where('LOWER(name) = ?', uom.downcase).first) if uom.present?
        product.update_attributes!(weight: weight) if product.respond_to?(:weight) && weight.present?
      end

      return_response('Product Updated Successfully.')
    rescue => e
      return_response(e.message, 0)
    end
  end

  attr_accessor :params
end
