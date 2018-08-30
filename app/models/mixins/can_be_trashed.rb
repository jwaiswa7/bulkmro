module Mixins::CanBeTrashed
  extend ActiveSupport::Concern

  included do
    class NotAllowed < StandardError; end

    default_scope { not_trashed }

    scope :trashed, -> { where.not(:trashed_uid => nil) }
    scope :not_trashed, -> { where(:trashed_uid => nil) }

    def trashed?
      trashed_uid.present?
    end

    def not_trashed?
      !trashed?
    end

    before_save :do_not_allow
    def do_not_allow
      raise NotAllowed if trashed? && !trashed_uid_changed?
    end
  end
end