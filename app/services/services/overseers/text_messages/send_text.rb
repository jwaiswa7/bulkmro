# The gems required for this service have been removed as on 16-07-2019
# Please add the gems 'twilio-ruby' and 'msg91ruby' in order to use the service.

include DisplayHelper

class Services::Overseers::TextMessages::SendText < Services::Shared::TextMessages::BaseService
  def initialize(use_alt_provider: false)
    @use_alt_provider = use_alt_provider
  end

  attr_reader :use_alt_provider
end
