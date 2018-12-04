class Services::Overseers::Inquiries::NewFromCustomerOrder < Services::Shared::BaseService

  def initialize(customer_order, current_overseer)
    @customer_order = customer_order
    @company = customer_order.company
    @overseer = current_overseer
  end

  def call
    inquiry = company.inquiries.build(
        inside_sales_owner: overseer,
        outside_sales_owner: company.outside_sales_owner || overseer,
        sales_manager: company.sales_manager,
        potential_amount: 0.1,
        billing_address: Address.find(customer_order.default_billing_address_id || company.default_billing_address_id || company.addresses.first),
        shipping_address: Address.find(customer_order.default_shipping_address_id || company.default_shipping_address_id || company.addresses.first),
        customer_po_number: customer_order.po_reference,
        overseer: overseer
    )

    ActiveRecord::Base.transaction do
      inquiry.save!
      customer_order.update_attributes(:inquiry_id => inquiry.id)

      customer_order.rows.each_with_index do |row, index|
        inquiry.inquiry_products.where(product_id: row.product.id).first_or_create(
            sr_no: index,
            quantity: row.quantity,
            bp_catalog_name: row.customer_product.name,
            bp_catalog_sku: row.customer_product.sku,
            product: row.product
        )
      end
    end

    inquiry
  end

  private

  attr_accessor :customer_order, :company, :overseer
end