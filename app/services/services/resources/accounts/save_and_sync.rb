

class Services::Resources::Accounts::SaveAndSync < Services::Shared::BaseService
  def initialize(account)
    @account = account
  end

  def call
    if account.save
      perform_later(account)
    end
  end

  def call_later
    if account.persisted?
      if account.remote_uid.present?
        ::Resources::BusinessPartnerGroup.update(account.remote_uid, account)
      else
        remote_uid = ::Resources::BusinessPartnerGroup.create(account)
        account.update_attributes(remote_uid: remote_uid) if remote_uid.present?
      end
    end
  end

  attr_accessor :account
end
