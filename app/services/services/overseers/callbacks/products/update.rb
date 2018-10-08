class Services::Overseers::Callbacks::Products::Update < Services::Shared::BaseService

  def initialize(params)
    @params = params
  end

  def call
    sku = params[:sku]
    uom = params[:uom_name]
    weight = params[:weight]

    product = Product.find_by_sku!(sku)

    if product.present?
      product.update_attributes!(:measurement_unit => MeasurementUnit.where('LOWER(name) = ?', uom.downcase).first) if uom.present?
      product.update_attributes!(:weight => weight) if product.respond_to?(:weight) && weight.present?
    end

    product
  end

  attr_accessor :params
end