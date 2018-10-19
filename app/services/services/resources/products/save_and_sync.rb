class Services::Resources::Products::SaveAndSync < Services::Shared::BaseService

  def initialize(product)
    @product = product
  end

  def call
    if product.save
      perform_later(product)
    end
  end

  def call_later
    if product.persisted?
      if product.remote_uid.blank?
        remote_uid = ::Resources::Item.custom_find(product.sku)
        product.update_attributes(:remote_uid => remote_uid) if remote_uid.present?
      elsif product.remote_uid.present?
        remote_uid = ::Resources::Item.custom_find(product.sku)
        product.update_attributes(:remote_uid => nil) if remote_uid.blank?
      end

      if product.remote_uid.present?
        ::Resources::Item.update(product.remote_uid, product)
      else
        product.update_attributes(:remote_uid => ::Resources::Item.create(product))
      end
    end
  end

  attr_accessor :product
end