class Services::Resources::Companies::SaveAndSync < Services::Shared::BaseService
  def initialize(company, options = false)
    @company = company
    @account = company.account
    @old_name = options
  end

  def call
    if company.save
      perform_later(company, old_name)
    end
  end

  def call_later
    if company.persisted?
      if account.remote_uid.blank?
        remote_uid = ::Resources::BusinessPartnerGroup.create(account)
        account.update_attributes(remote_uid: remote_uid) if remote_uid.present?
      end

      if old_name
        company_name = old_name[:name]
      else
        company_name = company.name
      end

      remote_uid = ::Resources::BusinessPartner.custom_find(company_name, company.is_supplier? ? 'cSupplier' : 'cCustomer')
      if remote_uid.present?
        company.update_attributes(remote_uid: remote_uid)
      end

      if company.remote_uid.blank?
        remote_uid = ::Resources::BusinessPartner.create(company)
        company.update_attributes(remote_uid: remote_uid) if remote_uid.present?
      else
        ::Resources::BusinessPartner.update(company.remote_uid, company)
      end
    end
  end

  attr_accessor :company, :account, :old_name
end
