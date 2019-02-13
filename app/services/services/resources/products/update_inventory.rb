class Services::Resources::Products::UpdateInventory < Services::Shared::BaseService
  def initialize(products)
    @products = products || Product.all
  end

  def call
    perform_later(products)
  end

  def call_later
    products_response = []
    next_link_count = nil
    loop do
      response = ::Resources::Item.find_inventory_info_for_all_items(next_link_count: next_link_count)
      validated_response = ::Resources::Item.get_validated_response(response)
      products_response.push validated_response["value"]
      next_link_count = validated_response["odata.nextLink"].split("=").last if validated_response["odata.nextLink"].present?
      break if !validated_response["odata.nextLink"].present? || next_link_count.to_i == 100
    end

    products_response.flatten.each do |product_response|
      product = Product.find_by_sku(product_response["ItemCode"])
      create_or_update_inventory_for(product, product_response) if product.present?
    end
  end

  def resync
    products.each do |product|
      response = ::Resources::Item.find_inventory_info_for_item(product.sku)
      validated_response = ::Resources::Item.get_validated_response(response)
      create_or_update_inventory_for(product, validated_response)
    end
  end

  def create_or_update_inventory_for(product, product_response)
    inventory_collections = product_response["ItemWarehouseInfoCollection"]
    if inventory_collections.present?
      inventory_collections.each do |inventory_detail|
        warehouse = Warehouse.find_by_remote_uid(inventory_detail["WarehouseCode"])
        warehouse_product_stock = WarehouseProductStock.where(warehouse_id: warehouse.id, product_id: product.id).first_or_create!
        warehouse_product_stock.update_attributes(instock: inventory_detail["InStock"].to_f, committed: inventory_detail["Committed"].to_f, ordered: inventory_detail["Ordered"].to_f)
      end
    end
  end

  attr_accessor :products
end
