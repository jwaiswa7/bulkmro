class Suppliers::RfqController < Suppliers::BaseController
  # before_action :set_purchase_order, only: [:show]

  def index
    authorize :rfq
  end

  def show

  end

  def edit_rfq_redirection

  end

  private

end
