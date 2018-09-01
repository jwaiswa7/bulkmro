class Overseers::Inquiries::SalesQuotesController < Overseers::Inquiries::BaseController
  def index
    @sales_quotes = @inquiry.sales_quotes
    authorize @sales_quotes
  end

  def new
    @sales_quote = Services::Overseers::SalesQuotes::BuildFromInquiry.new(@inquiry, current_overseer).call
    authorize @sales_quote
  end

  def create
    @sales_quote = SalesQuote.new(sales_quote_params.merge(:overseer => current_overseer))
    authorize @sales_quote

    if @sales_quote.save
      redirect_to overseers_inquiries_path, notice: flash_message(@inquiry, action_name)
    else
      render 'new'
    end
  end

  private
  def sales_quote_params
    params.require(:sales_quote).permit(
        :inquiry_id,
        :billing_address_id,
        :shipping_address_id,
        :comments,
        :sales_products_attributes => [
            :id,
            :product_id,
            :supplier_id,
            :quantity,
            :unit_cost_price,
            :margin,
            :unit_sales_price
        ]
    )
  end
end