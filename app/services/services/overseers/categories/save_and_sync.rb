class Services::Overseers::Categories::SaveAndSync < Services::Shared::BaseService

  def initialize(category)
    @category = category
  end

  def call
    if Rails.env.development?
      call_later
    else
      perform_later(category)
    end
  end

  def call_later
    if category.remote_uid.present?
      Resources::ItemGroup.update(category.remote_uid, category)
      category.save
    else
      category.remote_uid = Resources::ItemGroup.create(category)
      category.save
    end
  end

  attr_accessor :category
end