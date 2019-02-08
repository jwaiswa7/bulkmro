# frozen_string_literal: true

class Services::Resources::CompanyBanks::SaveAndSync < Services::Shared::BaseService
  def initialize(company_bank)
    @company_bank = company_bank
  end

  def call
    if company_bank.save
      perform_later(company_bank)
    end
  end

  def call_later
    company_bank.company.save_and_sync
  end

  attr_accessor :company_bank
end
