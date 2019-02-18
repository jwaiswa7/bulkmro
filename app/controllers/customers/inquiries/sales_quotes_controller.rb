class Customers::Inquiries::SalesQuotesController < Customers::Inquiries::BaseController
  before_action :set_final_sales_quote

  def index
  end

  def show
    respond_to do |format|
      format.html { }
      format.pdf do
        render_pdf_for @final_sales_quote
      end
    end
  end

  private

    def set_final_sales_quote
      @final_sales_quote = @inquiry.final_sales_quote
    end
end
