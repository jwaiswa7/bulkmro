

module Mixins::HasRemoteUid
  extend ActiveSupport::Concern

  included do
    validates_presence_of :remote_uid
    validates_uniqueness_of :remote_uid
  end
end
