class Services::Overseers::Products::SaveAndSync < Services::Shared::BaseService

  def initialize(product)
    @product = product
  end

  def call
    if Rails.env.development?
      call_later
    else
      perform_later(product)
    end
  end

  def call_later

    if product.persisted?
      if product.remote_uid.present?
        Resources::Item.update(product.remote_uid, product)
      else
        product.remote_uid = Resources::Item.create(product)
        product.save
      end
    end

  end

  attr_accessor :product
end