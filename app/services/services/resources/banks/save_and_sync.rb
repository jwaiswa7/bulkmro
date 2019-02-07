class Services::Resources::Banks::SaveAndSync < Services::Shared::BaseService

  def initialize(bank)
    @bank = bank
  end

  def call
    if bank.save
      perform_later(bank)
    end
  end

  def call_later
    if bank.persisted?
      if bank.remote_uid.present?
        ::Resources::Bank.update(bank.remote_uid, bank)
      else
        bank.update_attributes(:remote_uid => ::Resources::Bank.create(bank))
      end
    end
  end

  attr_accessor :bank
end