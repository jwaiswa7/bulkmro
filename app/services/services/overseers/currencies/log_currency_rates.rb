require 'money/bank/open_exchange_rates_bank'

class Services::Overseers::Currencies::LogCurrencyRates < Services::Shared::BaseService
  def initialize
  end

  def call
    Currency.non_inr.each do |currency|
      oxr = Money::Bank::OpenExchangeRatesBank.new
      oxr.app_id = '45dbf3d4fa144d718f18d559b754cbc7'
      oxr.update_rates

      Money.default_bank = oxr
      conversion_rate = Money.default_bank.get_rate(currency.name, Currency.inr.name)
      currency_rate = currency.current_rate || currency.figures.build
      currency_rate.assign_attributes(conversion_rate: conversion_rate)
      currency_rate.save!
    end
  end
end
