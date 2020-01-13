class Services::Resources::Products::UpdateInventoryForSaintGobain < Services::Shared::BaseService
  def initialize
  end

  def call
    perform_later()
  end

  def call_later
    products = CustomerProduct.where(company_id: 11420).map(&:product).uniq
    Services::Resources::Products::UpdateInventory.new(products).resync
  end
end
