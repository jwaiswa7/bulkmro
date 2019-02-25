# frozen_string_literal: true

class Overseers::Companies::SalesQuotesController < Overseers::Companies::BaseController
  def index
    @sales_quotes = ApplyDatatableParams.to(@company.sales_quotes, params.reject! { |k, _v| k == 'company_id' })
    authorize @sales_quotes
  end
end
