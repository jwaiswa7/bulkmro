class ResyncRemoteRequest < ApplicationRecord
  include Mixins::CanBeStamped
  include Mixins::IsARequest

  pg_search_scope :locate, :against => [:url], :associated_against => {}, :using => { :tsearch => { :prefix => true } }

  def error_message
    response['error']
  end

end
