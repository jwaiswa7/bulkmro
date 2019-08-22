class AclRole < ApplicationRecord
  include Mixins::CanBeStamped

  has_many :overseers

  # before_save :sort_resources

  def sort_resources
    role_resources = ActiveSupport::JSON.decode(self.role_resources)
    role_resources = role_resources.map {|x| x.to_i}
    role_resources = role_resources.sort {|x,y| (x <=> y)}
    role_resources.map {|x| x.to_s}
    self.role_resources = role_resources
  end

end
