class Services::Resources::Categories::SaveAndSync < Services::Shared::BaseService
  def initialize(category)
    @category = category
  end

  def call
    if category.save
      perform_later(category)
    end
  end

  def call_later
    if category.remote_uid.present?
      ::Resources::ItemGroup.update(category.remote_uid, category)
      category.save
    else
      category.remote_uid = ::Resources::ItemGroup.create(category)
      category.save
    end
  end

  attr_accessor :category
end
