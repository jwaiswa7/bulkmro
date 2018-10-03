class Services::Overseers::Industries::SaveAndSync < Services::Shared::BaseService

  def initialize(industry)
    @industry = industry
  end

  def call
    if industry.save!
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