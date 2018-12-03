class Overseers::CustomerOrders::InquiriesController < Overseers::CustomerOrders::BaseController
  def new
    @company = @customer_order.company
    @inquiry = @company.inquiries.build(
        inside_sales_owner: current_overseer,
        outside_sales_owner: @company.outside_sales_owner,
        sales_manager: @company.sales_manager,
        potential_amount: 0.1,
        billing_address: Address.find(@customer_order.default_billing_address_id),
        shipping_address: Address.find(@customer_order.default_shipping_address_id),
        customer_po_number: @customer_order.po_reference,
        overseer: current_overseer
    )

    ActiveRecord::Base.transaction do
      @inquiry.save
      @customer_order.inquiry = @inquiry
      @customer_order.save

      if @customer_order.present?
        sr_no = 0
        @customer_order.rows.each do |customer_order_row|
          sr_no = sr_no + 1
          @inquiry.inquiry_products.where(product: customer_order_row.product).first_or_create(
              sr_no: sr_no,
              quantity: customer_order_row.quantity,
              bp_catalog_name: nil,
              bp_catalog_sku: nil,
              product: customer_order_row.product
          )
        end
      end
    end

    authorize @inquiry

    redirect_to edit_overseers_inquiry_path(@inquiry), notice: flash_message(@inquiry, action_name)
  end
end
