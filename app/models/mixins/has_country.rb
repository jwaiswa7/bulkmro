# frozen_string_literal: true

module Mixins::HasCountry
  extend ActiveSupport::Concern

  included do
    def country_name
      country = ISO3166::Country[country_code]
      country.translations[I18n.locale.to_s] || country.name if country.present?
    end

    scope :domestic, -> { where(country_code: 'IN') }
    scope :international, -> { where.not(country_code: 'IN') }

    def domestic?
      country_code == 'IN'
    end

    def international?
      !domestic?
    end
  end
end
