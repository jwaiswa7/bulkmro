

include DisplayHelper

class Services::Overseers::TextMessages::SendText < Services::Shared::TextMessages::BaseService
  def initialize(use_alt_provider: false)
    @use_alt_provider = use_alt_provider
  end

  attr_reader :use_alt_provider
end
