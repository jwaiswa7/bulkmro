class Services::Overseers::Companies::SaveAndSync < Services::Shared::BaseService

  def initialize(company)
    @company = company
  end

  def call
    if Rails.env.development?
      call_later
    else
      perform_later(company)
    end

  end

  def call_later

    if company.persisted?
      if company.remote_uid.present?
        Resources::BusinessPartner.update(company.remote_uid, company)
      else
        company.remote_uid = Resources::BusinessPartner.create(company)
        company.save
      end
    end

  end

  attr_accessor :company
end