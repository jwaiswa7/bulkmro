# frozen_string_literal: true

module Mixins::CanBeSynced
  extend ActiveSupport::Concern

  included do
    def save_and_sync(options = false)
      if options
        service = ['Services', 'Resources', self.class.name.pluralize, 'SaveAndSync'].join('::').constantize.new(self, options)
      else
        service = ['Services', 'Resources', self.class.name.pluralize, 'SaveAndSync'].join('::').constantize.new(self)
      end

      service.call
      save if Rails.env.development?
    end

    def syncable_identifiers
      [:remote_uid]
    end

    def synced?
      syncable_identifiers.each do |si|
        return true if send(si).present?
      end

      false
    end

    def not_synced?
      !synced?
    end

    def sync_id
      legacy_id || id
    end
  end
end
