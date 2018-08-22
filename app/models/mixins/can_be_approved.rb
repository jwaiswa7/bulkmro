module Mixins::CanBeApproved
  extend ActiveSupport::Concern

  included do
    def approved?
      self.approval.present?
    end

    def not_approved?
      !approved?
    end
  end
end