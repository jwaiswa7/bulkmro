class Services::Resources::Products::UpdateRecentInquiryProductInventory < Services::Shared::BaseService
  def initialize
  end

  def call
    perform_later()
  end

  def call_later
    products = InquiryProduct.all.includes(:product).order(created_at: :desc).limit(1000).map{ |ip| ip.product }.uniq
    Services::Resources::Products::UpdateInventory.new(products).resync
  end
end
