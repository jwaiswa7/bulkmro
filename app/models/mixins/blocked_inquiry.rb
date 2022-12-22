module Mixins::BlockedInquiry
  extend ActiveSupport::Concern

  BLOCKED_INQUIRIES = YAML.load_file(Rails.root.join('config/blocked_inquiries.yml'))

  included do
    validate :is_not_blocked?
  end

  private
    # checks if the inquiry number is in the blocked inquiries files
    # will add a validation error if the inquiry exists in the blocked inquiries list and none otherwise.
    def is_not_blocked?
      inquiry_not_blocked = BLOCKED_INQUIRIES.select {|blockde_inquiry| blockde_inquiry['inquiry'] == inquiry_number }.empty?

      errors.add(:inquiry, 'is blocked') unless inquiry_not_blocked
    end
end
