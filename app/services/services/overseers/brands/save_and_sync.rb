class Services::Overseers::Brands::SaveAndSync < Services::Shared::BaseService

  def initialize(brand)
    @brand = brand
  end

  def call
    if brand.save!
      perform_later(brand)
    end
  end

  def call_later
    if brand.remote_uid.present?
      Resources::Manufacturer.update(brand.remote_uid, brand)
      brand.save
    else
      brand.remote_uid = Resources::Manufacturer.create(brand)
      brand.save
    end
  end

  attr_accessor :brand
end