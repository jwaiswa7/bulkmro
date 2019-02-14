

class Services::Overseers::Inquiries::RefreshSmartQueue < Services::Shared::BaseService
  def initialize
  end

  def call
    Inquiry.find_each(batch_size: 1000) do |inquiry|
      service = Services::Overseers::Inquiries::HandleSmartQueue.new(inquiry)
      service.call
    end
  end
end
