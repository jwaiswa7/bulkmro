class PoRequestComment < ApplicationRecord
  include Mixins::CanBeStamped
  belongs_to :po_request

  # validates_presence_of :message
end
