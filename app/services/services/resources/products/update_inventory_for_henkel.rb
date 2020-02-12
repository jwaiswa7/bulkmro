class Services::Resources::Products::UpdateInventoryForHenkel < Services::Shared::BaseService
  def initialize
  end

  def call
    perform_later()
  end

  def call_later
    products = CustomerProduct.where(company_id: 143).map(&:product).uniq
    Services::Resources::Products::UpdateInventory.new(products).resync
  end
end
