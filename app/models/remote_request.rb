class RemoteRequest < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::IsARequest

end
