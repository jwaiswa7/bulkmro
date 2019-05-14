class AclRole < ApplicationRecord
  include Mixins::CanBeStamped

  has_many :overseers

end
