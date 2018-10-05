class CurrencyRate < ApplicationRecord

  belongs_to :currency

  def self.save_fx_rate
    Currency.fx_currencies.each do |currency|
      begin
        fx_import = Services::Overseers::FxRates::OxrFxImporter.new()
        ex_rate = fx_import.get_fx_rate(Currency.base_currency, currency.name)
        if self.created_today(currency.id).present?
          self.created_today(currency.id).update(:currency_id => currency.id, :exchange_rate => ex_rate)
        else
          self.create(:currency_id => currency.id, :exchange_rate => ex_rate)
        end
      end
    end
  end

  private

  def self.created_today(currency_id)
    self.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).where(currency_id: currency_id)
  end

end
