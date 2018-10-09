module Mixins::CanBeSynced
  extend ActiveSupport::Concern

  included do
    def save_and_sync
      service = ['Services', 'Resources', self.class.name.pluralize, 'SaveAndSync'].join('::').constantize.new(self)
      service.call
    end

    def syncable_identifiers
      []
    end

    def synced?
      syncable_identifiers.each do |si|
        return true if self.send(si).present?
      end
    end

    def not_synced?
      synced?
    end

    def sync_id
      self.legacy_id || self.id
    end


  end
end