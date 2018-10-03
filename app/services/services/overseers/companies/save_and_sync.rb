class Services::Overseers::Companies::SaveAndSync < Services::Shared::BaseService

  def initialize(company)
    @company = company
    @account = company.account
  end

  def call
    if company.save!
      perform_later(company)
    end
  end

  def call_later
    if company.persisted?
      if account.remote_uid.blank?
        account.update_attributes(:remote_uid => Resources::BusinessPartnerGroup.create(account))
      end

      if company.remote_uid.present?
        Resources::BusinessPartner.update(company.remote_uid, company)
      else
        company.update_attributes(:remote_uid => Resources::BusinessPartner.create(company))
      end
    end
  end

  attr_accessor :company, :account
end