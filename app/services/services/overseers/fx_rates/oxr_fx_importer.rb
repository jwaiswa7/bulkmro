require 'money/bank/open_exchange_rates_bank'

class Services::Overseers::FxRates::OxrFxImporter < Services::Shared::BaseService

  def initialize()

  end

  def get_fx_rate(base_currency, fx_currency)
    oxr = Money::Bank::OpenExchangeRatesBank.new
    oxr.app_id = '45dbf3d4fa144d718f18d559b754cbc7'
    oxr.update_rates
    Money.default_bank = oxr
    Money.default_bank.get_rate(base_currency, fx_currency)
  end

end