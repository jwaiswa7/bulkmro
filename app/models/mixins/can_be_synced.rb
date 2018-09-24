module Mixins::CanBeSynced
  extend ActiveSupport::Concern

  included do
    def save_and_sync
      # service = ['Services', 'Overseers', self.class.name.pluralize, 'SaveAndSync'].join('::').constantize.new(self)
      # service.call
      self.save
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
  end
end