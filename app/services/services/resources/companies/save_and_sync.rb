class Services::Resources::Companies::SaveAndSync < Services::Shared::BaseService

  def initialize(company)
    @company = company
    @account = company.account
  end

  def call
    if company.save
      perform_later(company)
    end
  end

  def call_later
    if company.persisted?
      if account.remote_uid.blank?
        remote_uid = ::Resources::BusinessPartnerSupplierGroup.create(account)
        account.update_attributes(:remote_uid => remote_uid) if remote_uid.present?
      end

      if company.remote_uid.blank?
        remote_uid = ::Resources::BusinessPartner.custom_find(company.name)
        company.update_attributes(:remote_uid => remote_uid) if remote_uid.present?
      end

      if company.remote_uid.blank?
        remote_uid = ::Resources::BusinessPartner.create(company)
        company.update_attributes(:remote_uid => remote_uid) if remote_uid.present?
      else
        ::Resources::BusinessPartner.update(company.remote_uid, company)
      end
    end
  end

  attr_accessor :company, :account
end