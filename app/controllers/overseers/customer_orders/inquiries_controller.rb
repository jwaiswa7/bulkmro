# frozen_string_literal: true

class Overseers::CustomerOrders::InquiriesController < Overseers::CustomerOrders::BaseController
  def new
    authorize @customer_order, :can_create_inquiry?
    @inquiry = Services::Overseers::Inquiries::NewFromCustomerOrder.new(@customer_order, current_overseer).call
    redirect_to edit_overseers_inquiry_path(@inquiry), notice: flash_message(@inquiry, action_name)
  end
end
