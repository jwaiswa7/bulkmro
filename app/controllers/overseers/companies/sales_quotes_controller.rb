class Overseers::Companies::SalesQuotesController < Overseers::Companies::BaseController
  def index
    @sales_quotes = ApplyDatatableParams.to(@company.sales_quotes, params)
    authorize @sales_quotes
  end
end
