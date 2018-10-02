class Services::Overseers::industrys::SaveAndSync < Services::Shared::BaseService

  def initialize(industry)
    @industry = industry
  end

  def call
    if Rails.env.development?
      call_later
    else
      perform_later(industry)
    end
  end

  def call_later
    if industry.remote_uid.present?
      Resources::Industry.update(industry.remote_uid, industry)
      industry.save
    else
      industry.remote_uid = Resources::Industry.create(industry)
      industry.save
    end
  end

  attr_accessor :industry
end