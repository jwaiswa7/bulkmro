class Services::Resources::Brands::SaveAndSync < Services::Shared::BaseService
  def initialize(brand)
    @brand = brand
  end

  def call
    if brand.save
      perform_later(brand)
    end
  end

  def call_later
    if brand.remote_uid.present?
      ::Resources::Manufacturer.update(brand.remote_uid, brand)
    else
      remote_uid = ::Resources::Manufacturer.create(brand)
      brand.update_attributes(remote_uid: remote_uid) if remote_uid.present?
    end
  end

  attr_accessor :brand
end
